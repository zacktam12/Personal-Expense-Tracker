const express = require("express");
const router = express.Router();
const controller = require("../controllers/expenseController");

router.get("/", controller.getExpenses);
router.post("/", controller.addExpense);
router.delete("/:id", controller.deleteExpense);

module.exports = router;
