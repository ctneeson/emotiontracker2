document.addEventListener("DOMContentLoaded", function () {
    const emailInput = document.querySelector('input[name="email"]');
    const usernameInput = document.querySelector('input[name="username"]');
    const firstnameInput = document.querySelector(
      'input[name="firstname"]'
    );
    const lastnameInput = document.querySelector('input[name="lastname"]');
    const passwordInput = document.querySelector('input[name="userpass"]');
    const createAccountButton = document.querySelector(
      ".create-account-button"
    );

    const validateInputs = () => {
      const inp_email = emailInput.value.trim();
      const emailLength = inp_email.length;
      const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

      const inp_password = passwordInput.value.trim();
      const passwordLength = inp_password.length;
      const passwordPattern = /^[^\s]+$/;

      createAccountButton.disabled =
        !inp_email ||
        !emailPattern.test(inp_email) ||
        emailLength < 3 ||
        emailLength > 250 ||
        passwordLength < 3 ||
        passwordLength > 50 ||
        !passwordPattern.test(inp_password);
    };

    const handleApiResponse = (data) => {
      console.log("data:", data);

      if (data.status === "success") {
        UIkit.modal.confirm(`${data.message}: continue to login?`).then(
          function () {
            window.location.href = `/login`;
          },
          function () {}
        );
      } else {
        UIkit.notification({
          message: `<strong>${data.status.toUpperCase()}</strong>: ${
            data.message
          }`,
          status: "danger",
          pos: "top-right",
          timeout: 5000,
        });
      }
    };

    const handleSubmit = async (event) => {
      event.preventDefault();
      validateInputs();

      if (!createAccountButton.disabled) {
        const username = usernameInput.value.trim();
        const useUsername = username && !/^\s+$/.test(username);
        const inp_email = emailInput.value.trim();
        const inp_name = useUsername ? username : inp_email;
        const inp_firstname = firstnameInput.value.trim();
        const inp_lastname = lastnameInput.value.trim();
        const inp_password = passwordInput.value.trim();

        UIkit.modal.confirm("Continue with account creation?").then(
          function () {
            console.log(
              "User confirmed. Proceeding with account creation."
            );

            const user_details = {
              user_details: {
                inp_name,
                inp_firstname,
                inp_lastname,
                inp_email,
                inp_password,
                inp_typeid: 2,
              },
            };
            console.log("user_details:", user_details);

            $.post(
              "http://localhost:3002/useradmin/users/new",
              user_details,
              handleApiResponse
            );
          },
          function () {
            console.log("User canceled account creation.");
          }
        );
      }
    };

    emailInput.addEventListener("input", validateInputs);
    passwordInput.addEventListener("input", validateInputs);

    document.querySelector("form").addEventListener("submit", handleSubmit);

    validateInputs();
  });