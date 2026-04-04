const router = require('express').Router();
const Hospital = require('../models/Hospital');
const authMiddleware = require('../middleware/auth');
const QRCode = require('qrcode');
const Doctor = require('../models/Doctor');

// Create hospital (admin only)
router.post('/', async (req, res) => {
  try {
    const { name, address, departments } = req.body;
    const hospital = new Hospital({ name, address, departments });
    await hospital.save();
    res.status(201).json(hospital);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get all hospitals
router.get('/', async (req, res) => {
  try {
    const hospitals = await Hospital.find();
    res.json(hospitals);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get departments of a hospital
router.get('/:id/departments', async (req, res) => {
  try {
    const hospital = await Hospital.findById(req.params.id);
    if (!hospital) return res.status(404).json({ message: 'Hospital not found' });

    res.json({ departments: hospital.departments });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Generate booking QR for a doctor (hospital prints this)
router.get('/qr/:doctorId', async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.params.doctorId)
      .populate('hospital', 'name');

    if (!doctor) return res.status(404).json({ message: 'Doctor not found' });

    // This URL opens the booking page in the Flutter app or web
    const bookingUrl = `mediqueue://book?doctorId=${doctor._id}&hospitalId=${doctor.hospital._id}&department=${encodeURIComponent(doctor.department)}`;

    // Generate QR as base64 image
    const qrImage = await QRCode.toDataURL(bookingUrl, {
      width: 300,
      margin: 2,
      color: {
        dark: '#1a73e8',
        light: '#ffffff'
      }
    });

    res.json({
      doctorId: doctor._id,
      doctorName: doctor.name,
      department: doctor.department,
      hospitalName: doctor.hospital.name,
      bookingUrl,
      qrImage  // base64 PNG — use directly in <img src="...">
    });

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

const QRCode = require('qrcode');   // add to top of hospitals.js
 
// PUT /api/hospitals/:id  — edit hospital profile
router.put('/:id', async (req, res) => {
  try {
    const { name, address, departments } = req.body;
    const update = {};
    if (name)        update.name        = name;
    if (address)     update.address     = address;
    if (departments) update.departments = Array.isArray(departments)
      ? departments
      : departments.split(',').map(d => d.trim()).filter(Boolean);
 
    const hospital = await Hospital.findByIdAndUpdate(
      req.params.id,
      { $set: update },
      { new: true, runValidators: true }
    );
    if (!hospital) return res.status(404).json({ message: 'Hospital not found' });
    res.json(hospital);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});
 
// DELETE /api/hospitals/:id  — remove a hospital and its doctors
router.delete('/:id', async (req, res) => {
  try {
    const hospital = await Hospital.findByIdAndDelete(req.params.id);
    if (!hospital) return res.status(404).json({ message: 'Hospital not found' });
 
    // Cascade-delete all doctors belonging to this hospital
    await Doctor.deleteMany({ hospital: req.params.id });
 
    res.json({ message: 'Hospital deleted', id: req.params.id });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});
 
// GET /api/hospitals/:id/reception-qr
// Returns a base64 PNG of the hospital-level reception QR code.
// Patients scan this at the front desk to see all doctors.
router.get('/:id/reception-qr', async (req, res) => {
  try {
    const hospital = await Hospital.findById(req.params.id);
    if (!hospital) return res.status(404).json({ message: 'Hospital not found' });
 
    const payload = `mediqueue://hospital?id=${req.params.id}`;
    const qrDataUrl = await QRCode.toDataURL(payload, {
      width: 400,
      margin: 2,
      color: { dark: '#0F172A', light: '#FFFFFF' },
      errorCorrectionLevel: 'H',
    });
 
    res.json({
      hospitalId: req.params.id,
      hospitalName: hospital.name,
      payload,
      qrDataUrl,   // base64 PNG — use directly in <img src="...">
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;