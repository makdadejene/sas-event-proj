# Quad

## Team Members

- Makda Dejene (msd2214)
- Marionna Saunders (mvs2147)
- Kevin Arista Solis(ka2902)
- Sophie Agbekpenou (saa2255)

## Project Overview

Quad allows students to post and browse campus events. Users can create events with a title, description, date, time, tags, and optionally an image. Events can be sorted by date or alphabetically.

## Features

- Browse all events
- Sort/filter events by date or alphabetically
- Create new events via a form
- Add tags to categorize events

## Getting Started

### Prerequisites

- Ruby 3.x
- Rails 7.x
- PostgreSQL
- Node.js and Yarn

### Setup Instructions

1. **Clone the repository:**
   \`\`\`bash
   git clone https://github.com/makdadejene/sas-event-proj.git
   cd sas-event-proj
   \`\`\`

2. **Install dependencies:**
   \`\`\`bash
   bundle install
   yarn install
   \`\`\`

3. **Setup the database:**
   \`\`\`bash
   rails db:create
   rails db:migrate
   rails db:seed
   \`\`\`

4. **Start the Rails server:**
   \`\`\`bash
   rails server
   \`\`\`

5. **Visit the app:**
   Open your browser and go to [http://localhost:3000](http://localhost:3000)

### Running Tests

#### RSpec

\`\`\`bash
bundle exec rspec
\`\`\`

#### Cucumber

\`\`\`bash
bundle exec cucumber
\`\`\`
