// Upvote functionality
document.addEventListener('DOMContentLoaded', function() {
  // Handle upvote submission
  document.querySelectorAll('.submit-upvote').forEach(button => {
    button.addEventListener('click', function() {
      const modal = this.closest('.modal');
      const form = modal.querySelector('.upvote-form');
      const eventId = form.dataset.eventId;
      const username = form.querySelector('[name="username"]').value;
      const email = form.querySelector('[name="email"]').value;
      const errorDiv = form.querySelector('.error-message');
      const successDiv = form.querySelector('.success-message');

      // Clear previous messages
      errorDiv.classList.add('d-none');
      successDiv.classList.add('d-none');

      // Validate form
      if (!username || !email) {
        showError(errorDiv, 'Please fill in all fields');
        return;
      }

      // Disable button during submission
      this.disabled = true;
      this.textContent = 'Submitting...';

      // Get CSRF token
      const csrfToken = document.querySelector('[name="csrf-token"]').content;

      // Submit upvote
      fetch(`/events/${eventId}/upvotes`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({
          upvote: {
            username: username,
            email: email
          }
        })
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          // Update upvote count
          const countElement = document.querySelector(`.upvote-container[data-event-id="${eventId}"] .upvote-count`);
          if (countElement) {
            countElement.textContent = data.upvote_count;
          }

          // Show success message
          showSuccess(successDiv, data.message);
          
          // Store email in localStorage for this session
          localStorage.setItem(`upvoted_${eventId}`, email);

          // Close modal after 1.5 seconds
          setTimeout(() => {
            const modalElement = bootstrap.Modal.getInstance(modal);
            if (modalElement) modalElement.hide();
            form.reset();
            successDiv.classList.add('d-none');
          }, 1500);
        } else {
          showError(errorDiv, data.error);
        }
      })
      .catch(error => {
        showError(errorDiv, 'An error occurred. Please try again.');
        console.error('Error:', error);
      })
      .finally(() => {
        // Re-enable button
        this.disabled = false;
        this.textContent = 'Submit Upvote';
      });
    });
  });

  // Helper functions
  function showError(element, message) {
    element.textContent = message;
    element.classList.remove('d-none');
  }

  function showSuccess(element, message) {
    element.textContent = message;
    element.classList.remove('d-none');
  }

  // Check if user has already upvoted (from localStorage)
  document.querySelectorAll('.upvote-container').forEach(container => {
    const eventId = container.dataset.eventId;
    const hasUpvoted = localStorage.getItem(`upvoted_${eventId}`);
    
    if (hasUpvoted) {
      const btn = container.querySelector('.upvote-btn');
      btn.classList.add('upvoted');
      btn.disabled = true;
    }
  });
});