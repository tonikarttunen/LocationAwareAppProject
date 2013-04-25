# READ ME

This app allows the user to find points of interest nearby. You can select
whether to use the new Apple Local Search API, Foursquare API v.2 or Google Places API 
to find local search results. It is also possible to use this app to check in to 
Foursquare places. 

*Note: the application works best on a real iOS device. It may not work in the Simulator.*

![Figure 1. Foursquare local search results.](/DocumentationImages/Trending.png "Figure 1. Foursquare local search results.") ![Figure 2. Google Maps 3D View.](/DocumentationImages/Pittsburgh.png "Figure 2. Google Maps 3D View.")

## Getting the Required API Keys

Before using the app, you must obtain the required API keys.

### Foursquare

Go to https://foursquare.com/developers/apps and click the `Create a New App` button.
The the required information to the form and click changes (figure 1). The redirect URL should be
the same as the URL scheme in the Info.plist file of the app. In this case, enter the
following redirect URLs: `tonikarttunen://com.tonikarttunen.LocationAwareApp, app://tonikarttunen`.

![Figure 3. Creating a new Foursquare app.](/DocumentationImages/NewFoursquareApp.png "Figure 3. Creating a new Foursquare app.")

After saving the information, you should see a page that similar to the one below.
Open the APIConstants.h file in Xcode. Copy the client ID and the client secret from the Foursquare app info page and paste them to the APIConstants.h file.

![Figure 4. Foursquare app info page.](/DocumentationImages/FoursquareAppInfo.png "Figure 4. Foursquare app info page.") 

### Google Maps iOS SDK

Follow the instructions that are available at
[https://developers.google.com/maps/documentation/ios/start](https://developers.google.com/maps/documentation/ios/start).

Add the API key to the APIConstants.h file.

### Google Places API

Follow the instructions that are available at
[https://developers.google.com/places/documentation/](https://developers.google.com/places/documentation/).

Add the API key to the APIConstants.h file.

## Building and Running the App

Open the `LocationAwareApp.xcodeproj` file with Xcode.
Choose a build scheme by clicking the Scheme dropdown menu on Xcode's toolbar (see the image below). You have three options: Foursquare, Google and Apple.

![Figure 5. Choosing a build scheme.](/DocumentationImages/BuildSchemeSettings.png "Figure 5. Choosing a build scheme.")

### Build Requirements

+ iOS 6.1 or later
+ Xcode 4.5 or later (tested with Xcode 4.6.1)

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

Copyright (C) 2011-2013 [Ba-Z Communication Inc.](http://www.ba-z.co.jp/). All rights reserved.

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

## zlib Copyright Notice

This software is based in part on zlib:
Copyright (c) 1995-2012 Jean-loup Gailly and Mark Adler

## OpenGL Utility Library License

This software is based in part on GLU (OpenGL Utility Library):

SGI FREE SOFTWARE LICENSE B (Version 2.0, Sept. 18, 2008)
Copyright (C) 2000 Silicon Graphics, Inc. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice including the dates of first publication and either
this permission notice or a reference to http://oss.sgi.com/projects/FreeB/
shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL SILICON
GRAPHICS, INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of Silicon Graphics, Inc. shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from Silicon Graphics, Inc.

## iGLU License

This software is based in part on iGLU [https://code.google.com/p/iphone-glu/](https://code.google.com/p/iphone-glu/):

The MIT License (MIT)
Copyright (c) 2008 Christopher Stawarz

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
