# Quad

## Team Members

- Makda Dejene (msd2214)
- Marionna Saunders (mvs2147)
- Kevin Arista Solis(ka2902)
- Sophie Agbekpenou (saa2255)

## Heroku Link

https://quad-events-app-a4f62440aa74.herokuapp.com/

## Project Overview

Quad allows students to post and browse campus events. Students can post and interact with a wide variety of events, whether casual or club-sponsored.

## Features

- Browse Events: View all campus events in a visually appealing grid layout
- Sort & Filter: Sort events alphabetically, by date (earliest/latest first), or by default order
- Create Events: Simple form to post new events with all relevant details
- Responsive Design: Modern, gradient-styled interface that works on all device
- Sign in: Users can sign in using google authentication
- Edit/Delete Events: Users can edit/delete events that they created
- Filter by Tags: Events are filtered based on tags
- Upvotes: Events can be upvoted by users (only once per user) and this will influence order
- Unlisted: Event will not show up on feed if unlisted is checked.
- Share: Share event via multiple platforms.

## Getting Started

### Prerequisites

- Ruby 3.x
- Rails 7.x
- PostgreSQL
- Node.js
- Yarn

### Local Setup Instructions

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

4. **Google Auth Set Up**
   - Create a `.env` file in the root folder
   - Add the following environment variables:
     ```
     GOOGLE_CLIENT_ID=your_google_client_id
     GOOGLE_CLIENT_SECRET=your_google_client_secret
     ```
   - The exact API keys will be included in the submission comments

5. **Start the Rails server:**
   \`\`\`bash
   rails server
   \`\`\`


### Running Tests

#### RSpec

\`\`\`bash
bundle exec rspec
\`\`\`

#### Cucumber

\`\`\`bash
bundle exec cucumber
\`\`\`
