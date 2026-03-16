---
description: For linking the backend to this flutter app
---

You Need to Link the backend to our Flutter Code

the Full source code for both frontend and backend is in this folder: @F:\eduprova\EDUPROVA
it has source code for :
    - backend: implemented using Nest.js + fastify , code at: @F:\eduprova\EDUPROVA\backend
    - frontend: implemented using Next.js (react,typescript,tailwind) at @F:\eduprova\EDUPROVA\frontend

the backend uses swaggar for docs, to get api : http://localhost:4000/docs or http://<IPADDRESS>:4000/docs to get the api docs, if backend not runs, run using :  npm run start

So to Link the backend to our Flutter Code check the source code of backend and also check swagger docs. also check Next.Js frontend code how it uses the same backend. 


we are using dio for @/lib/core/network for network requests
- create a repository class to write logic to fetch data