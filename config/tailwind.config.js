const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  darkMode: 'class',
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './config/initializers/simple_form_tailwind.rb',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/components/**/*.{html.erb,rb}',
  ],
  theme: {
    extend: {
      borderRadius: {
        pv2: 'var(--pv2-radius)',
        'pv2-lg': 'var(--pv2-radius-lg)',
      },
      boxShadow: {
        pv2: 'var(--pv2-shadow)',
      },
      colors: {
        pv2: {
          accent: 'var(--pv2-accent)',
          'accent-border': 'var(--pv2-accent-border)',
          'accent-solid': 'var(--pv2-accent)',
          'accent-soft': 'var(--pv2-accent-soft)',
          'accent-text': 'var(--pv2-accent-text)',
          bg: 'var(--pv2-bg)',
          'bg-soft': 'var(--pv2-bg-soft)',
          border: 'var(--pv2-border)',
          'border-strong': 'var(--pv2-border-strong)',
          muted: 'var(--pv2-muted)',
          subtle: 'var(--pv2-subtle)',
          surface: 'var(--pv2-surface)',
          'surface-strong': 'var(--pv2-surface-strong)',
          text: 'var(--pv2-text)',
        },
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
        pv2: ['var(--p-font-family)'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
