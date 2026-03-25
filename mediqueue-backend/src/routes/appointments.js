const router = require('express').Router();
const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');
const authMiddleware = require('../middleware/auth');

// Book appointment
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { doctorId, hospitalId, department, type } = req.body;

    // Get today's date as YYYY-MM-DD
    const today = new Date().toISOString().split('T')[0];

    // Find doctor to get avg consultation time
    const doctor = await Doctor.findById(doctorId);
    if (!doctor) return res.status(404).json({ message: 'Doctor not found' });

    // Count existing appointments for this doctor today
    const existingCount = await Appointment.countDocuments({
      doctor: doctorId,
      date: today,
      status: { $in: ['waiting', 'serving'] }
    });

    // Generate token number
    const tokenNumber = existingCount + 1;

    // Calculate estimated wait time
    // Emergency patients go to the front, normal patients go to the back
    let estimatedWaitTime;
    if (type === 'emergency') {
      // Count how many are currently being served or are emergency ahead
      const currentlyServing = await Appointment.findOne({
        doctor: doctorId,
        date: today,
        status: 'serving'
      });
      estimatedWaitTime = currentlyServing ? doctor.avgConsultationTime : 0;
    } else {
      estimatedWaitTime = existingCount * doctor.avgConsultationTime;
    }

    const appointment = new Appointment({
      patient: req.user.id,
      doctor: doctorId,
      hospital: hospitalId,
      department,
      tokenNumber,
      type: type || 'normal',
      date: today,
      estimatedWaitTime
    });

    await appointment.save();

    // Populate and return full appointment details
    const populated = await Appointment.findById(appointment._id)
      .populate('patient', 'name phone')
      .populate('doctor', 'name department avgConsultationTime')
      .populate('hospital', 'name');

    // Emit socket event so queue updates in real time
    const io = req.app.get('io');
    io.emit(`queue:${doctorId}`, { type: 'NEW_APPOINTMENT', appointment: populated });

    res.status(201).json(populated);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get my appointments (patient)
router.get('/my', authMiddleware, async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];

    const appointments = await Appointment.find({
      patient: req.user.id,
      date: today
    })
      .populate('doctor', 'name department')
      .populate('hospital', 'name')
      .sort({ tokenNumber: 1 });

    res.json(appointments);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get all appointments for a doctor today (admin/queue view)
router.get('/doctor/:doctorId', authMiddleware, async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];

    const appointments = await Appointment.find({
      doctor: req.params.doctorId,
      date: today,
      status: { $in: ['waiting', 'serving'] }
    })
      .populate('patient', 'name phone')
      .populate('doctor', 'name department')
      .sort([['type', -1], ['tokenNumber', 1]]);
      // emergency first (-1), then by token number

    res.json(appointments);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;