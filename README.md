# Bite Your Thumb

#### What's in a Name?

My shortlived career as a stage performer came to a frothing crest in grade school when I played [Abram of House Montague](http://www.sparknotes.com/shakespeare/romeojuliet/characters.html). Of the 5 or so lines I was required to memorize, none were as monumetally impactful as:[**"Do you bite your thumb at us, sir?"**](http://nfs.sparknotes.com/romeojuliet/page_8.html). 

> "...thumb biting, which involves biting and then flicking one's thumb from behind the upper teeth, is a Shakespearean version of flipping someone the bird"
> \- [Shmoop.com](http://www.shmoop.com/romeo-and-juliet/thumb-biting-symbol.html) 

My young mind was delighted by an offensive gesture that could be used indiscriminately without fear (because no one knew what the hell it meant). Somehow the phrase/gesture has stuck with me some seventeen years later. When the project was determined to be an insult generator, I knew I wanted to honor my past thespian acheivement. And so, *Bite Your Thumb* was chosen. 

#### Overview

This app was originally an extra-curricular project I put together for student of mine while I was an instructor at Coallition4Queens (now, [Pursuit](https://www.pursuit.org/)). The students were looking for a challenge and I was looking for a way to satisfy my urge to build something. In short, I came up with the idea of making a simple insult generator using a (now defunct) api, FOAAS (F*ck off as a Service). You can read about the original project [here](https://accesslite.github.io/BYT-Golden/), including methodology, motivation and thoughts from the team. 

Fast forward a few years and now my urges include rewriting old projects using a modern architecture. So BYT serves as a good jumping off point to showcase how Swift has changed and how I've evolved as a developer. I really only have two guiding principles: 

1. Keep the original spirit of the app intact
2. Use modern tech & standards

#### The Standards

1. Programmatic autolayout (no 3rd party libraries)
  2. CollectionVC's using Compositional Layout
4. Self-hosted, updated FOAAS API
  5. Add new endpoints for new features
6. Generic network layer (no 3rd party libraries)
7. Combine for fun, even if it's a bit contrived

#### Step 1: The API

In the intervening 7 or so years since this project was created, both backend APIs we had used no longer exist. Well, Fieldbook which was used for versioning and color themes no longer exists. However, FOAAS lived on as an unmaintained repo.  So, naturally I forked the project, detached it from the original source (because I need that sweet, sweet contribution cred) and began to look for hosting options for Node apps. 

I settled on [Render](https://render.com/) because it was free and setup was incredibly easy for a node app. So, now the API lives on as [foaas.onrender.com](https://foaas.onrender.com). 

I wasn't happy with the API as it was, so I've made a few changes to it with some assistance from Copilot, which you can check out [here](https://github.com/spacedrabbit/foaas-1). It was mainly removing some operations I didn't like and adding a new `message of the day` endpoint to use as a landing screen. 

#### Step 2: The design

Was a bit sparse and outdated. To keep the app's original spirit, I decided I would model it closer to a daily affirmations/inpirations quote app by taking the profane madlibs being generated and overlaying them on lovely images of landscapes from the [Upsplash API](https://unsplash.com/documentation). Now, their free API tier limits you to 50 requests an hour, so I decided to get around that limitation by doing an initial request for `N` number of random photos and then caching them locally for use. To make this process easier, as it's not really the focus of my goals, I use [Kingfisher](https://github.com/onevcat/Kingfisher) for image download, caching and `UIImageView` extensions for handling image downloads. 
