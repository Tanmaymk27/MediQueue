const router = require('express').Router();
const Doctor = require('../models/Doctor');
const authMiddleware = require('../middleware/auth');

// Add a doctor (admin only)
router.post('/', async (req, res) => {
  try {
    const { name, hospital, department, avgConsultationTime } = req.body;

    const doctor = new Doctor({
      name,
      hospital,
      department,
      avgConsultationTime: avgConsultationTime || 10
    });

    await doctor.save();
    res.status(201).json(doctor);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get doctors by hospital and department
router.get('/', async (req, res) => {
  try {
    const { hospitalId, department } = req.query;

    const filter = {};
    if (hospitalId) filter.hospital = hospitalId;
    if (department) filter.department = department;

    const doctors = await Doctor.find(filter).populate('hospital', 'name');
    res.json(doctors);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get single doctor
router.get('/:id', async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.params.id).populate('hospital', 'name');
    if (!doctor) return res.status(404).json({ message: 'Doctor not found' });
    res.json(doctor);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const { name, department, avgConsultationTime } = req.body;
    const update = {};
    if (name)                update.name                = name;
    if (department)          update.department          = department;
    if (avgConsultationTime) update.avgConsultationTime = parseInt(avgConsultationTime);
 
    const doctor = await Doctor.findByIdAndUpdate(
      req.params.id,
      { $set: update },
      { new: true, runValidators: true }
    ).populate('hospital', 'name');
 
    if (!doctor) return res.status(404).json({ message: 'Doctor not found' });
    res.json(doctor);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});
 
// DELETE /api/doctors/:id  — remove a doctor
router.delete('/:id', async (req, res) => {
  try {
    const doctor = await Doctor.findByIdAndDelete(req.params.id);
    if (!doctor) return res.status(404).json({ message: 'Doctor not found' });
    res.json({ message: 'Doctor deleted', id: req.params.id });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;