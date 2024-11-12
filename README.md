# Cardinal Real-Time Communication Tutorial

This repository contains the example code used in the [real-time communication tutorial](https://docs.icure.com/tutorial/pubsub/).

It shows the use case of a patient-oriented application that publishes medical data and a backend service that has to
perform an analysis whenever a new piece of information is created.

The patient application is simulated by the Publisher. The Publisher logs in as a healthcare party, creates a patient
user, and uses the patient user to simulate the creation of samples by a device that measures the sugar level in blood.
Each one of these samples is also shared of with the healthcare party.

The backend service is simulated by the Subscriber. The Subscriber logs in as a healthcare party and opens a websocket
to listen to all the creation events of the entities shared with them with a specific tag. Whenever a new entity is
created, the Subscriber assigns a tag to it.

The tutorial code is available in Kotlin, Python, and TypeScript. Below you will find instructions for running the code
in all three languages. For further explanations and examples, check the [Cardinal documentation](https://docs.icure.com/).