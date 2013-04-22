# READ ME

This app allows the user to find points of interest nearby. You can select
whether to use the new Apple Local Search API, Foursquare API v.2 or Google Places API 
to find local search results. It is also possible to use this app to check in to 
Foursquare places. 

**Status: ALPHA (not ready for prime time)**

## Usage Instructions

## Getting the Required API Keys

### Foursquare

Go to https://foursquare.com/developers/apps and click the `Create a New App` button.
The the required information to the form and click changes (figure 1). The redirect URL should be
the same as the URL scheme in the Info.plist file of the app. In this case, enter the
following redirect URLs: `tonikarttunen://com.tonikarttunen.LocationAwareApp, app://tonikarttunen`.

![Figure 1. Creating a new Foursquare app.](/DocumentationImages/NewFoursquareApp.png "Figure 1. Creating a new Foursquare app.")

After saving the information, you should see a page that similar to the one below.
Open the APIConstants.h file in Xcode. Copy the client ID and the client secret from the Foursquare app info page and paste them to the APIConstants.h file.

![Figure 2. Foursquare app info page.](/DocumentationImages/FoursquareAppInfo.png "Figure 2. Foursquare app info page.") 

### Google Maps iOS SDK

Follow the instructions that are available at
[https://developers.google.com/maps/documentation/ios/start](https://developers.google.com/maps/documentation/ios/start).

Add the API key to the APIConstants.h file.

### Google Places API

Follow the instructions that are available at
[https://developers.google.com/places/documentation/](https://developers.google.com/places/documentation/).

Add the API key to the APIConstants.h file.

## Building and Running the App

Choose a build scheme by clicking the Scheme dropdown menu on Xcode's toolbar (see the image below). You have three options: Foursquare, Google and Apple.

![Figure 3. Choosing a build scheme.](/DocumentationImages/BuildSchemeSettings.png "Figure 3. Choosing a build scheme.")

### Build Requirements

+ iOS 6.1 or later
+ Xcode 4.4 or later (tested with Xcode 4.6.1)

## Acknowledgements

[Foursquare API v2 for iOS](https://github.com/baztokyo/foursquare-ios-api)
was developed by [Ba-Z Communication Inc.](http://www.ba-z.co.jp/)

## License

Copyright (c) 2013, Toni Antero Karttunen
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the name of Toni Antero Karttunen nor the
   names of the other contributors of the software may be used to endorse or promote
   products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL TONI ANTERO KARTTUNEN BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Foursquare API v2 for iOS License

The following license applies to the Foursquare API:

Copyright (C) 2011-2013 Ba-Z Communication Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
