const db = require("./db");

exports.getAllExpenses = (callback) => {
  db.query("SELECT * FROM expenses ORDER BY date DESC", callback);
};

exports.addExpense = (data, callback) => {
  db.query("INSERT INTO expenses SET ?", data, callback);
};

exports.deleteExpense = (id, callback) => {
  db.query("DELETE FROM expenses WHERE id = ?", [id], callback);
};
