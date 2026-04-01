const express = require('express');
const router = express.Router();

// 🔥 FINAL WORKING API (NO DB, NO AUTH)

router.post('/', async (req, res) => {
  try {
    console.log("🔥 API HIT");
    console.log("BODY:", req.body);

    const { doctor, hospital, department } = req.body;

    // simple validation
    if (!doctor || !hospital || !department) {
      return res.status(400).json({ message: "Missing fields" });
    }

    // generate token
    const tokenNumber = Math.floor(Math.random() * 1000);

    return res.status(201).json({
      doctor,
      hospital,
      department,
      tokenNumber,
      status: "waiting",
      date: new Date().toISOString().split("T")[0],
    });

  } catch (err) {
    console.error("ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;