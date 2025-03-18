// main.js

document.addEventListener('DOMContentLoaded', () => {
    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Contact form handling
    const contactForm = document.getElementById('contact-form');
    if (contactForm) {
        contactForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const email = e.target.querySelector('input[type="email"]').value;
            
            try {
                // Here you would typically send the email to your backend
                console.log('Email submitted:', email);
                
                // Show success message
                const button = e.target.querySelector('button');
                const originalText = button.textContent;
                button.textContent = 'Thanks!';
                button.style.backgroundColor = '#10B981';
                
                // Reset form
                e.target.reset();
                
                // Reset button after 2 seconds
                setTimeout(() => {
                    button.textContent = originalText;
                    button.style.backgroundColor = '';
                }, 2000);
            } catch (error) {
                console.error('Error submitting form:', error);
            }
        });
    }

    // Intersection Observer for fade-in animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Observe all feature cards
    document.querySelectorAll('.feature-card').forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'all 0.6s ease-out';
        observer.observe(card);
    });

    // Add hover effect to navigation
    const nav = document.querySelector('nav');
    if (nav) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 0) {
                nav.style.backgroundColor = 'rgba(255, 255, 255, 0.9)';
                nav.style.boxShadow = '0 2px 4px rgba(0, 0, 0, 0.1)';
            } else {
                nav.style.backgroundColor = 'rgba(255, 255, 255, 0.8)';
                nav.style.boxShadow = 'none';
            }
        });
    }
}); 