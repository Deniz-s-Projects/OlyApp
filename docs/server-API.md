# OlyApp Server API

REST endpoints exposed by the Node/Express server under `/api`.

Source of truth: `server/routes/*.js`. This document is a navigation aid;
when in doubt, read the route file.

## Conventions

- **Base URL**: `${API_BASE}/api`
- **Auth**: most routes require a `Authorization: Bearer <jwt>` header. JWTs
  are issued by `/auth/login` or `/auth/register` and contain `{ userId }`.
- **Admin**: routes that mutate shared state typically gate writes behind
  `middleware/requireAdmin.js`, which loads `User.findById(req.userId)` and
  rejects when `!user.isAdmin`.
- **Response shape**: most routes wrap payloads in `{ data: ... }`; errors
  come back as `{ error: <message> }` with a 4xx/5xx status.
- **IDs**: legacy collections (events, items, bulletin posts, comments,
  …) use a numeric `id` field maintained by a per-collection `nextId`
  helper. User IDs are Mongo `ObjectId` strings.

## Endpoint reference

### `/auth`
Public.
- `POST /register` — create user + return JWT
- `POST /login` — exchange credentials for a JWT
- `POST /reset` — request a password-reset token
- `POST /reset/confirm` — consume the token and set a new password

### `/users`
Authenticated.
- `GET /` — list users in the public directory
- `PUT /me` — update the current user's profile
- `POST /me/avatar` — upload avatar (multer)
- `DELETE /me` — delete the current account
- `PUT /:id` — admin only: edit any user
- `DELETE /:id` — admin only: delete a user

### `/events`
Authenticated; write paths gated behind admin where noted in source.
- `GET /` — list events
- `POST /` — create event
- `PUT /:id` — edit event
- `DELETE /:id` — remove event
- `POST /:id/rsvp` — toggle RSVP for the current user
- `GET /:id/attendees` — list RSVPs
- `GET /:id/comments` — list event comments
- `POST /:id/comments` — add a comment
- `GET /:id/qr` — issue a check-in QR token
- `POST /:id/checkin` — record an attendance scan

### `/items` (item exchange)
- `GET /` — list items
- `POST /` — create listing
- `GET /:id/messages` — chat history with item owner
- `POST /:id/messages` — send chat message
- `POST /:id/request` — request the item
- `POST /:id` — edit listing (owner)
- `POST /:id/delete` — delete listing (owner)
- `POST /:id/ratings` — submit rating after handoff
- `GET /:id/ratings` — list ratings

### `/maintenance`
- `GET /` / `POST /` — list / create requests
- `GET /:id/messages` / `POST /:id/messages` — chat thread
- `PUT /:id` — admin only: update status
- `DELETE /:id` — admin only: remove

### `/bookings`
- `GET /slots` / `POST /slots` — list / create bookable slots
- `GET /slots/manage` — admin slot management
- `DELETE /slots/:id` — admin remove slot
- `GET /` / `POST /` — list / create bookings
- `GET /my` — current user's bookings
- `DELETE /:id` — cancel booking

### `/bulletin`
- `GET /` / `POST /` — list / create posts
- `PUT /:id` — edit post (author only)
- `DELETE /:id` — delete post (author or admin)
- `GET /:id/comments` / `POST /:id/comments` — list / add comments
- `PUT /:postId/comments/:commentId` — edit comment (author only)
- `DELETE /:postId/comments/:commentId` — delete comment (author or admin)

### `/channels` (group chat)
- `POST /` — create channel
- `POST /:id/participants` — add member
- `DELETE /:id/participants/:userId` — remove member
- `GET /:id/messages` / `POST /:id/messages` — history / send

### `/clubs`
- `GET /` / `POST /` — list / create
- `GET /:id` / `PUT /:id` / `DELETE /:id` — read / edit / remove
- `POST /:id/join` — toggle club membership

### `/directory`
- `GET /` — public directory listing
- `GET /:id/messages` / `POST /:id/messages` — 1:1 chat

### `/documents`
- `GET /` / `POST /` — list / upload (multer)

### `/emergency_contacts`
- `GET /` — public list
- `POST /` / `PUT /:id` / `DELETE /:id` — admin only

### `/gallery`
- `GET /` / `POST /` — list / upload

### `/job_posts`
- `GET /` / `POST /` — list / create
- `PUT /:id` / `DELETE /:id` — edit / remove (author)

### `/lostfound`
- `GET /` (filters: `search`, `type`, `resolved`) — list
- `POST /` — create
- `GET /:id/messages` / `POST /:id/messages` — chat with owner
- `POST /:id/resolve` — mark resolved
- `POST /:id` / `POST /:id/delete` — edit / delete (owner)

### `/noise_reports`
- `GET /` — admin only
- `POST /` — submit report

### `/notifications`
- `POST /register` — register device token
- `POST /send` — admin-targeted push
- `POST /broadcast` — admin: push to every registered device

### `/pins` (map)
- `GET /` — list pins
- `POST /` / `POST /:id` / `DELETE /:id` — admin manage

### `/polls`
- `GET /` / `POST /` — list / create (admin)
- `POST /:id/vote` — cast vote
- `DELETE /:id` — admin remove

### `/security_reports`
- `GET /` / `GET /:id` — admin browse
- `POST /` — submit
- `PUT /:id` / `DELETE /:id` — admin

### `/services` (service listings)
- `GET /` / `POST /` — list / create
- `PUT /:id` / `DELETE /:id` — edit / remove (author)
- `POST /:id/ratings` / `GET /:id/ratings` — rate / list ratings

### `/stats`
- `GET /` — dashboard summary
- `GET /monthly` — monthly counts

### `/studygroups`
- `GET /` / `POST /` — list / create
- `GET /:id` / `PUT /:id` / `DELETE /:id` — read / edit / remove
- `POST /:id/join` / `POST /:id/leave` — membership

### `/suggestions`
- `GET /` — list
- `POST /` — submit
- `PUT /:id` / `DELETE /:id` — admin

### `/tutoring`
- `GET /` / `POST /` — list / create

### `/wiki`
- `GET /` — list articles
- `GET /:id` — read article
- `POST /` / `PUT /:id` / `DELETE /:id` — admin only
