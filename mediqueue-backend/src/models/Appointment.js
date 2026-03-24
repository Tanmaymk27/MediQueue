const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  patient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  doctor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Doctor',
    required: true
  },
  hospital: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Hospital',
    required: true
  },
  department: {
    type: String,
    required: true
  },
  tokenNumber: {
    type: Number,
    required: true
  },
  type: {
    type: String,
    enum: ['normal', 'emergency'],
    default: 'normal'
  },
  status: {
    type: String,
    enum: ['waiting', 'serving', 'completed', 'cancelled'],
    default: 'waiting'
  },
  date: {
    type: String,  // stored as "YYYY-MM-DD" for simplicity
    required: true
  },
  estimatedWaitTime: {
    type: Number,  // in minutes
    default: 0
  }
}, { timestamps: true });

module.exports = mongoose.model('Appointment', appointmentSchema);