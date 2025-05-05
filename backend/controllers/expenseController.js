const Expense = require("../models/expenseModel");

exports.getExpenses = (req, res) => {
  Expense.getAllExpenses((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

exports.addExpense = (req, res) => {
  const newExpense = req.body;
  Expense.addExpense(newExpense, (err, result) => {
    if (err) return res.status(500).json(err);
    res.status(201).json({ id: result.insertId, ...newExpense });
  });
};

exports.deleteExpense = (req, res) => {
  const { id } = req.params;
  Expense.deleteExpense(id, (err) => {
    if (err) return res.status(500).json(err);
    res.status(204).send();
  });
};
