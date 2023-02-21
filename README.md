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
- Loading states
- Auto-refresh
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


## Expected Usage

The idea is that this is a complete a consolidated 'app' experience completely independent of reliance on the API. There is no dependency, but an `OMGDataInterface` instance is expected to be passed into the first and primary view. In theory those are the only things that should actually be exposed from a api level, but that's neither the current state nor the expectation for the future, I'll likely keep Views for Widgets and such in here as well, even if not exposed through the core app.

By default there is the SampleData interface, which is offline, artifically delayed on some calls, and not providing very clean data. I'd love to clean it up to use consistent+random (lol) delays when fetching content. The client is expected to provide any other DataInterfaces it expects to use. My app has a `OMGAPIDataInterface` that hits the actual [omg.lol api](https://api.omg.lol) through [my Swift package](https://github.com/iCalvin-Actual/api.omg.lol), but that isn't included in this package for reasons that make sense to me.
