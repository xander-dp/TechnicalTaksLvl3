# Short description:

Project uses [Random API](https://randomuser.me/documentation#howto) to get a list of Users.
App uses Session to fixate list of Users during 10 minutes since last login.
On startup App checks if there is a valid session and in this case will run screen with previously Data (if some).
Otherwise it will request to authorise.

# Tech stack

App implemented using MVVM + C and using Combine as a binding mechanism.
For concurrency operations (i.e. network requests) used Swift Concurrency
Data stored in CoreData and NSUserDefaults
UI implemented in code, utilizing UIKit

# Notes

1. There is 5 hardcoded steps to simulate App initialization before session check; summary awaiting set to 3-5 seconds
2. App uses pagination for data requests, and session's UUID as a "seed" parameter. It allows to get same sequence of data for session.
3. In case of successful reading of stored session it will be automatically updated for another 10 minutes.
4. After downloading, data stored in Core Data, for caching purposes and to ensure uniqueness.
5. On each launch of UsersList Screen app will try to display data stored in CoreData or performing request if there is no stored data.
6. App retreiving new data-page(by default 20 items) each time when you reach the last element in TableView
7. In purpose of simplicity received user's email considered as a unique record's parameter.
8. Remote data considered as a source of truth, so in case of refresh all stored data will be deleted and download will start over.
9. Stored data will be also deleted in case of logout and in case when App tries to reach storage with new Session

# Known issues:
Core Data implementation is not threadsafe
