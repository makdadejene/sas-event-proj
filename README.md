# Quad

## Team Members

- Makda Dejene (msd2214)
- Marionna Saunders (mvs2147)
- Kevin Arista Solis(ka2902)
- Sophie Agbekpenou (saa2255)

## Heroku Link

https://quad-events-app-a4f62440aa74.herokuapp.com/

## Project Overview

Quad allows students to post and browse campus events. Users can create events with a title, description, date, time, tags, and optionally an image. Events can be sorted by date or alphabetically. Events can also be filtered by tags and are sorted by upvotes. Users can also sign in using google and are able to edit/delete events.

## Features

- Browse Events: View all campus events in a visually appealing grid layout
- Sort & Filter: Sort events alphabetically, by date (earliest/latest first), or by default order
- Create Events: Simple form to post new events with all relevant details
- Responsive Design: Modern, gradient-styled interface that works on all device
- Sign in: Users can sign in using google authentication
- Edit/Delete Events: Users can edit/delete events that they created
- Filter by Tags: Events are filtered based on tags
- Upvotes: Events can be upvoted by users (only once per user) and this will influence order

## Getting Started

### Prerequisites

- Ruby 3.x
- Rails 7.x
- PostgreSQL
- Node.js
- Yarn

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
