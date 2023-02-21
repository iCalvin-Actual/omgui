# ui.app.lol

A Swift Package that UI and Data Models for the core SwiftUI App behind [app.lol]()

____

## Current Status

### Features

<details>
<summary>
Supported
</summary>

- Address Directory
  - Search
- Address Profile
  - Show Web Profile
  - Show 'Now' Markdown (not formatted correctly :/)
  - Show Status Log
  - Show PURLs
  - Show PasteBin
- Community Status Log
- Now Garden


</details>

<details>
<summary>
Immediate Next Steps
</summary>

- Thoughtful pass of UI + UX
- Pin/Un-Pin addresses
- Block/Un-Block addresses
- Implement a 'Shareable' protocol
  - Share as Link, Content, or Image

</details>

<details>
<summary>
MVP
</summary>

- Authentication
  - Logged out View for Auth Sheet
  - Logged in View for Auth Sheet
  - Show My Addresses
  - Auth-pin My Addresses after Login
- Posting
  - Status
  - Profile Updates
  - Now Update
  - PURL
  - Paste
- Paywall
  - Answer Unknowns
    - How does that work with TestFlight?
    - Can I build that within the UI Package?
    - What to expose
    - When to present
  - Confetti


</details>


### Authentication

Authentication is not yet supported, I'm trying to esttablish a firm base of the Read-only experience first, and then add the layer of authentication and composing new content on top of that.

I also intend to let authentication be the Paywall. So you can read, browse, pin, block, share, all you want, but to login and update your content I'm thinking $5/year. It seems like a reasonable addition to the core services fee of $20/year.



