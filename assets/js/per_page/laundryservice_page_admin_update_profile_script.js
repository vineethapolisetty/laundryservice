// Simple validation before submit
document.addEventListener("DOMContentLoaded", function () {
  var form = document.getElementById("profileForm");
  if (!form) return;

  form.addEventListener("submit", function (e) {
    var email = form.querySelector("input[name=email]").value.trim();
    if (!email.includes("@")) {
      e.preventDefault();
      alert("Please enter a valid email address.");
    }
  });
});
