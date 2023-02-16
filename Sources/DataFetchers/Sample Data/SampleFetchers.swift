//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/15/23.
//

import Foundation

class SampleSettingsFetcher: AppModelDataFetcher {
    override func update() {
        blockList = ["appreview"]
        serviceInfo = .sample
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.directory = ["app", "calvin", "jwithy", "jmj", "kris", "spalger", "joshbrez"].map { name in
                    .init(
                        name: name,
                        url: nil,
                        registered: Date()
                    )
            }
        }
    }
}

class SampleStatusLogFetcher: StatusLogDataFetcher {
    let directory = ["app", "calvin", "jwithy", "jmj", "kris", "spalger", "joshbrez"]
    
    override func update() {
        var statuses: [StatusModel?] = []
        for _ in 0...50 {
            statuses.append(.random(from: directory.randomElement()))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.statuses = statuses
                .compactMap({ $0 })
                .filter({ element in
                    guard !self.addresses.isEmpty else {
                        return true
                    }
                    return false
                })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.fetchLatest()
        }
    }
    
    func fetchLatest() {
        var new: [StatusModel?] = []
        for _ in 0...50 {
            new.append(.random(from: directory.randomElement()))
        }
        
        self.statuses.append(contentsOf: new
            .compactMap({ $0 })
            .filter({ element in
                guard !self.addresses.isEmpty else {
                    return true
                }
                return false
            }))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.fetchLatest()
        }
    }
}

class SampleAddressDataFetcher: AddressDetailsDataFetcher {
    
    init(name: AddressName) {
        super.init(
            name: name,
            profileFetcher: SampleProfileFetcher(name: name),
            nowFetcher: SampleNowFetcher(name: name),
            purlFetcher: SamplePURLsFetcher(name: name),
            pasteFetcher: SamplePasteBinFetcher(name: name)
        )
    }
    
    override func update() {
        profileFetcher?.update()
        nowFetcher?.update()
    }
}

class SampleNowFetcher: AddressNowDataFetcher {
    override func update() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.content = """
### Some Title

Some Markdown content. **Formatting** *support* expected.

- A
- List
"""
            self.updated = Date()
            self.listed = false
        }
    }
}

class SamplePURLsFetcher: AddressPURLsDataFetcher {
    override func update() {
        let new: [PURLModel] = [
            .random(from: addressName),
            .random(from: addressName),
            .random(from: addressName)
        ]
        .compactMap({ $0 })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.purls = new
        }
    }
}

class SamplePasteBinFetcher: AddressPasteBinDataFetcher {
    override func update() {
        let new: [PasteModel] = [
            .random(from: addressName),
            .random(from: addressName),
            .random(from: addressName)
        ]
        .compactMap({ $0 })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.pastes = new
        }
    }
}

class SampleProfileFetcher: AddressProfileDataFetcher {
    override func update() {
        self.html = """
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>
      app.lol for iOS
    </title>
    <meta charset="utf-8">
    <meta property="og:type" content="website">
    <meta property="og:title" content="app.lol for iOS">
    <meta property="og:description" content="An Apple Native Client for omg.lol">
    <meta property="og:image" content="https://profiles.cache.lol/app/picture?v=1676318189.7229">
    <meta name="viewport" content="width=device-width">
    <link href="https://cdn.cache.lol/profiles/themes/css/base.css" rel="stylesheet">
    <link href="https://cdn.cache.lol/profiles/themes/css/purplegray.css" rel="stylesheet">
    <style>
                #footer .prami-logo {
                        height: 1em;
                        transition: all 0.3s ease;
                        margin: 0 .3em -.1em 0;
                }
                #footer:hover .prami-logo {
                        transform: scale(1.5) rotate(20deg);
                        transition: all 0.3s ease;
                }
    </style>
  </head>
  <body>
    <main>
      <div id="profile-picture-container">
        <img alt="app" id="profile-picture" src="https://profiles.cache.lol/app/picture?v=1676318189.7229">
      </div>
      <h1 id="name">
        app.lol
      </h1>
      <div class="metadata" id="pronouns">
        they/them
      </div>
      <div class="metadata" id="occupation">
        <i class="fa-solid fa-fw fa-briefcase"></i> App Client
      </div>
      <div id="details"></div>
      <div id="bio">
        <h3>
          Coming Soon
        </h3>
        <p>
          Are you as much a fan of <a rel="me" href="http://home.omg.lol">omg.lol</a> as we are?
        </p>
        <h4>
          YES!
        </h4>
        <p>
          We thought so!! We’re putting together a (hopefully) great native app experience, send an email to sign up for the <a rel="me" href="mailto:app@omg.lol">beta list</a> or keep up with development on our <a rel="me" href="/now">Now Page</a>
        </p>
        <h4>
          Wait, what is this?
        </h4>
        <p>
          Ooh, are you in for a treat! If you’re interested in any of the following:
        </p>
        <ul class="fa-ul">
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Having a web presence
          </li>
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Reaching people who enjoy your work
          </li>
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Staying in touch with people you love
          </li>
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Sharing links
          </li>
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Sharing thoughts
          </li>
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Email aliases
          </li>
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Supporting the open internet
          </li>
        </ul>
        <p>
          <a rel="me" href="https://home.omg.lol">omg.lol</a> is gonna get you really excited.
        </p>
        <h4>
          Okay, that’s that, who are you?
        </h4>
        <p>
          We are <code>app.lol</code>, a native client to the <code>omg.lol</code> service.
        </p>
        <p>
          Let’s break that down:
        </p>
        <p>
          <strong>Native</strong> - <code>app.lol</code> is built to run on and take advantage of Apple platforms, using modern APIs and design language, supporting system features, and exist as a thouroughly considered tool to help you, the user.
        </p>
        <p>
          <strong>Client</strong> - As nice as the web interface to <code>omg.lol</code> is, sometimes the jump to a web browser is enough to stop you from completing a thought. <code>app.lol</code> aims to help that using the <a rel="me" href="https://api.omg.lol">public APIs</a> exposed by the service. Put it right on your phone, your Mac, your iPad, your TV, wherever it fits for you.
        </p>
        <p>
          <strong>omg.lol Service</strong> - Update your <a rel="me" href="https://home.omg.lol/info/now">Now Page</a>, check the links on your profile, draft a new status and pick just the right emoji. Now you can do all of the above without needing to open a web browser.
        </p>
        <h3>
          What are you waiting for?
        </h3>
        <p>
          That's the pitch! By now you should know whether you're interested or not :) Please feel free to reach out with any questions, comments, gripes, concerns, complaints...
        </p>
        <p>
          <a rel="me" href="mailto://app@omg.lol">app@omg.lol</a>
        </p>
        <p>
          Follow development! We'll try to pose semi-regular updates on our <a rel="me" href="/now">Now Page</a>.
        </p>
      </div>
      <div id="footer">
        <a href="https://home.omg.lol/referred-by/app"><img class="prami-logo" src="https://cdn.cache.lol/img/prami_hybrid.svg"> Powered by omg.lol</a>
      </div>
    </main>
  </body>
</html>
"""
    }
}
