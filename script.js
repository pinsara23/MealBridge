document.addEventListener('DOMContentLoaded', () => {
    // DOM Elements
    const form = document.getElementById('reset-password-form');
    const newPasswordInput = document.getElementById('new-password');
    const confirmPasswordInput = document.getElementById('confirm-password');
    const matchError = document.getElementById('password-match-error');
    const submitBtn = document.getElementById('submit-btn');
    const btnText = submitBtn.querySelector('.btn-text');
    const loader = submitBtn.querySelector('.loader');
    const messageContainer = document.getElementById('form-message');

    // State
    let token = '';

    // 1. Extract Token from URL
    try {
        const urlParams = new URLSearchParams(window.location.search);
        token = urlParams.get('token');

        if (!token) {
            handleError('Invalid or missing reset token. Please use the link provided in your email.');
            // Disable form if no token
            disableForm();
        } else {
            console.log('Token extracted:', token);
            // Optional: Store token in a hidden field if you prefer, but variable is fine
        }
    } catch (e) {
        console.error('Error parsing URL:', e);
        handleError('An error occurred while validating your request.');
        disableForm();
    }

    // 2. Real-time Password Match Validation
    confirmPasswordInput.addEventListener('input', () => {
        validateMatch();
    });

    newPasswordInput.addEventListener('input', () => {
        if (confirmPasswordInput.value) validateMatch();
    });

    function validateMatch() {
        const password = newPasswordInput.value;
        const confirm = confirmPasswordInput.value;

        if (password && confirm && password !== confirm) {
            matchError.classList.remove('hidden');
            // confirmPasswordInput.setCustomValidity("Passwords do not match");
            // We'll handle custom styling instead of browser default
            return false;
        } else {
            matchError.classList.add('hidden');
            // confirmPasswordInput.setCustomValidity("");
            return true;
        }
    }

    // 3. Form Submission
    form.addEventListener('submit', async (e) => {
        e.preventDefault();

        // Clear previous messages
        clearMessage();

        // Validate Token
        if (!token) {
            handleError('Missing reset token.');
            return;
        }

        // Validate Passwords
        if (!validateMatch()) {
            // Shake animation or focus
            confirmPasswordInput.focus();
            return;
        }

        const newPassword = newPasswordInput.value;
        const confirmPassword = confirmPasswordInput.value;

        if (newPassword.length < 8) {
            handleError('Password must be at least 8 characters long.');
            return;
        }

        // Prepare Request
        const payload = {
            token: token,
            newPassword: newPassword
        };

        // UI Loading State
        setLoading(true);

        try {
            // Simulate API call delay for UX (remove in production if desired, but good for "feel")
            // await new Promise(r => setTimeout(r, 800)); 

            const response = await fetch('http://192.168.43.35:8080/api/auth/reset-password', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            });

            if (response.ok) {
                // Success (200 OK)
                handleSuccess('Success! You can now login.');
                form.reset();
                disableForm(); // Prevent duplicate submissions or changes

                // Optional: Redirect after a few seconds
                // setTimeout(() => window.location.href = '/login', 3000);
            } else {
                // Error (4xx, 5xx)
                // Try to parse error message from server
                let errorMsg = 'Invalid or expired token.';
                try {
                    const errorData = await response.json();
                    if (errorData.message) {
                        errorMsg = errorData.message;
                    }
                } catch (parseError) {
                    console.warn('Could not parse error response JSON', parseError);
                }

                handleError(errorMsg);
            }

        } catch (networkError) {
            console.error('Network Validation Error:', networkError);
            handleError('Network error. Please try again later.');
        } finally {
            setLoading(false);
        }
    });

    // Helper Functions
    function setLoading(isLoading) {
        submitBtn.disabled = isLoading;
        if (isLoading) {
            btnText.classList.add('hidden');
            loader.classList.remove('hidden');
        } else {
            btnText.classList.remove('hidden');
            loader.classList.add('hidden');
        }
    }

    function handleError(msg) {
        messageContainer.textContent = msg;
        messageContainer.className = 'message error'; // Reset classes
        messageContainer.classList.remove('hidden');
    }

    function handleSuccess(msg) {
        messageContainer.textContent = msg;
        messageContainer.className = 'message success'; // Reset classes
        messageContainer.classList.remove('hidden');
    }

    function clearMessage() {
        messageContainer.classList.add('hidden');
        messageContainer.textContent = '';
    }

    function disableForm() {
        newPasswordInput.disabled = true;
        confirmPasswordInput.disabled = true;
        submitBtn.disabled = true;
    }
});
