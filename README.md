# Parallel project
Made for KTU Parallel programming module, using Ruby and experimental Ractor library
## Task
Task is to create a program, that would only pass data through actor Distributor "Skirstytuvas"
Main sends data one at a time to "Skirstytuvas" which then has to distribute the data as evenly as possible to the Workers "Darbininkai". There can be any amount of workers
after data is processed it sends it back to "Skirstytuvas". "Dskirstytuvas" then sends it to Accumulator "Rezultatų Kaupiklis" which stores data, then when all data is recevied sends it back to "Skirstytuvas" which in turn sends it to the Printer "Spausdintojas" which then prints and returns done message to "Skirstytuvas". Each Message received and sent by "Skirstytuvas" is logged in actor "Zurnalas".
There are two result files: rez.txt and zurnalas.txt
- Zurnalas.txt is the log
- rez.txt is the filtered and printed data
