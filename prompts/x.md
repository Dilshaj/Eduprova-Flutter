currently we are fetching network requests in provides, we are writing all network requess in those, instead create those network requests in seperately and use/call them .

search for where we are using ApiClient  and create some centeralized way to define all those.

also currently we using always courses/id it on etches non buy course details i think, for who bought i think they should use courses/id/learn i think, i exactly don't know.
please check backend and frontend of next.js source code for more details how they use : 