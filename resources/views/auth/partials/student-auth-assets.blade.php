@push('styles')
    <style>
        body {
            background: #f5f7fb;
        }

        .student-auth-shell {
            min-height: 100vh;
            display: grid;
            grid-template-columns: minmax(420px, 45.3vw) 1fr;
            background: #f6f7fb;
        }

        .student-auth-brand {
            position: relative;
            overflow: hidden;
            min-height: 100vh;
            padding: 42px 48px;
            color: white;
            background:
                radial-gradient(circle at 82% 12%, rgba(255, 255, 255, 0.14) 0 0, transparent 18rem),
                linear-gradient(140deg, #5660d8 0%, #7f90ed 58%, #9ab8f6 100%);
            display: flex;
            flex-direction: column;
        }

        .student-auth-logo {
            position: relative;
            z-index: 2;
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .student-auth-logo span,
        .student-auth-benefits span {
            flex: 0 0 auto;
            width: 56px;
            height: 56px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid rgba(255, 255, 255, 0.34);
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.13);
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.16);
            backdrop-filter: blur(10px);
        }

        .student-auth-logo strong {
            display: block;
            font-size: 1.35rem;
            line-height: 1.05;
            font-weight: 800;
            letter-spacing: 0;
        }

        .student-auth-logo small {
            display: block;
            color: rgba(255, 255, 255, 0.92);
            font-size: 0.94rem;
            font-weight: 700;
        }

        .student-auth-copy {
            position: relative;
            z-index: 2;
            width: min(520px, 100%);
            margin-top: auto;
            margin-bottom: 9rem;
        }

        .student-auth-copy h1 {
            color: white;
            font-size: clamp(2.3rem, 4.5vw, 3.95rem);
            line-height: 1.08;
            font-weight: 800;
            letter-spacing: 0;
            margin-bottom: 1.35rem;
        }

        .student-auth-copy p {
            color: rgba(255, 255, 255, 0.85);
            font-size: 1.18rem;
            line-height: 1.65;
            margin: 0;
        }

        .student-auth-shapes span {
            position: absolute;
            border: 1px solid rgba(255, 255, 255, 0.22);
            border-radius: 22px;
            background: rgba(255, 255, 255, 0.12);
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.14);
            backdrop-filter: blur(10px);
        }

        .student-auth-shapes .shape-one {
            width: 200px;
            height: 122px;
            right: 50px;
            top: 32%;
        }

        .student-auth-shapes .shape-two {
            width: 140px;
            height: 70px;
            right: 100px;
            top: calc(32% + 74px);
        }

        .student-auth-benefits {
            position: relative;
            z-index: 2;
            display: grid;
            gap: 20px;
        }

        .student-auth-benefits div {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .student-auth-benefits span {
            width: 45px;
            height: 45px;
            font-size: 1rem;
        }

        .student-auth-benefits p {
            margin: 0;
        }

        .student-auth-benefits strong,
        .student-auth-benefits small {
            display: block;
        }

        .student-auth-benefits strong {
            color: white;
            font-size: 1rem;
            margin-bottom: 0.12rem;
        }

        .student-auth-benefits small {
            color: rgba(255, 255, 255, 0.8);
            font-size: 0.91rem;
            line-height: 1.35;
        }

        .student-auth-main {
            min-height: 100vh;
            padding: 48px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .student-auth-card {
            width: min(560px, 100%);
        }

        .student-auth-card-wide {
            width: min(700px, 100%);
        }

        .student-auth-heading {
            margin-bottom: 2.9rem;
        }

        .student-auth-heading h2 {
            color: #171b29;
            font-size: clamp(2rem, 3vw, 2.55rem);
            line-height: 1.08;
            font-weight: 800;
            letter-spacing: 0;
            margin-bottom: 0.85rem;
        }

        .student-auth-heading p {
            color: #748197;
            font-size: 1.12rem;
            margin: 0;
        }

        .student-auth-form {
            display: grid;
            gap: 1.55rem;
        }

        .student-auth-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1.2rem;
        }

        .student-auth-field label,
        .student-auth-label-row label {
            color: #202433;
            font-size: 1rem;
            font-weight: 800;
            margin-bottom: 0.75rem;
        }

        .student-auth-label-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
        }

        .student-auth-label-row a {
            color: #5360d9;
            font-size: 0.95rem;
            font-weight: 700;
            margin-bottom: 0.75rem;
        }

        .student-auth-input {
            min-height: 56px;
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 0 14px;
            background: white;
            border: 1px solid #d5dce9;
            border-radius: 12px;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .student-auth-input:focus-within {
            border-color: #6b76e7;
            box-shadow: 0 0 0 4px rgba(91, 103, 222, 0.12);
        }

        .student-auth-input i {
            color: #718098;
            font-size: 1rem;
        }

        .student-auth-input input,
        .student-auth-input select {
            width: 100%;
            min-width: 0;
            border: 0;
            outline: 0;
            background: transparent;
            color: #222739;
            font: inherit;
            padding: 0.95rem 0;
        }

        .student-auth-input input::placeholder {
            color: #758197;
        }

        .student-auth-input select {
            appearance: none;
            cursor: pointer;
        }

        .student-auth-select {
            position: relative;
        }

        .student-auth-select::after {
            content: "\f078";
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            color: #718098;
            pointer-events: none;
        }

        .password-toggle {
            width: 34px;
            height: 34px;
            flex: 0 0 auto;
            border: 0;
            background: transparent;
            color: #718098;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
        }

        .password-toggle:hover {
            background: #f3f5fb;
        }

        .student-auth-submit {
            width: 100%;
            min-height: 56px;
            border: 0;
            border-radius: 18px;
            color: white;
            background: linear-gradient(90deg, #5960d7, #96b6f5);
            font-size: 1.12rem;
            font-weight: 800;
            box-shadow: 0 20px 36px rgba(87, 96, 214, 0.22);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .student-auth-submit:hover {
            transform: translateY(-1px);
            box-shadow: 0 24px 42px rgba(87, 96, 214, 0.28);
        }

        .student-auth-footer {
            margin-top: 2.55rem;
            text-align: center;
        }

        .student-auth-footer p {
            color: #7d8797;
            margin: 0;
            font-size: 1rem;
        }

        .student-auth-footer a {
            color: #5360d9;
            font-weight: 800;
        }

        @media (max-width: 1100px) {
            .student-auth-shell {
                grid-template-columns: 1fr;
            }

            .student-auth-brand {
                min-height: auto;
                padding: 32px;
            }

            .student-auth-copy {
                margin: 4rem 0 3rem;
            }

            .student-auth-benefits {
                grid-template-columns: repeat(3, minmax(0, 1fr));
            }

            .student-auth-main {
                min-height: auto;
                padding: 42px 24px;
            }
        }

        @media (max-width: 760px) {
            .student-auth-brand {
                padding: 28px 22px;
            }

            .student-auth-copy h1 {
                font-size: 2.4rem;
            }

            .student-auth-copy p {
                font-size: 1rem;
            }

            .student-auth-benefits {
                grid-template-columns: 1fr;
            }

            .student-auth-grid {
                grid-template-columns: 1fr;
            }

            .student-auth-main {
                padding: 34px 18px;
            }

            .student-auth-heading {
                margin-bottom: 2rem;
            }

            .student-auth-heading h2 {
                font-size: 2rem;
            }

            .student-auth-shapes {
                display: none;
            }
        }
    </style>
@endpush

@push('scripts')
    <script>
        document.querySelectorAll('.password-toggle').forEach((button) => {
            button.addEventListener('click', () => {
                const input = document.getElementById(button.dataset.target);
                const icon = button.querySelector('i');
                const showing = input.type === 'text';

                input.type = showing ? 'password' : 'text';
                button.setAttribute('aria-label', showing ? 'Show password' : 'Hide password');
                icon.classList.toggle('fa-eye', showing);
                icon.classList.toggle('fa-eye-slash', !showing);
            });
        });
    </script>
@endpush
