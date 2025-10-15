
# Blueprint: Flutter Learning App

## Overview

This application is a Duolingo-inspired learning app. It started with a Firebase authentication feature and is now expanding to include a character writing practice module.

## Implemented Features (v1)

*   **Firebase Authentication:**
    *   User login via Google Sign-In.
    *   A home page displaying the user's name and email after successful login.
    *   A sign-out button.
*   **Core Backend Setup:**
    *   Firebase Core, Auth, Google Sign-In.
    *   Firestore Database for storing user data (though not fully utilized yet).

## Current Plan: Duolingo-style Writing Practice

This plan outlines the creation of a new feature: a multi-step writing practice module for learning Hanzi characters, inspired by the Duolingo UI.

### 1. New Screen: `WritingPracticeScreen`

*   A new, dedicated screen will be created to house the learning experience.
*   It will be a stateful widget to manage the user's progress through the different steps of the lesson.
*   The UI will feature a dark theme with blue accent colors, mimicking the provided screenshots.

### 2. Lesson Flow for the character "茶" (tea)

The module will guide the user through a series of exercises in a specific order:

1.  **Step 1: Select Meaning (Multiple Choice)**
    *   Question: "Select the correct meaning".
    *   Character: "茶".
    *   Options: ["tea", "coffee", "add"].
    *   Correct Answer: "tea".

2.  **Step 2: Trace the Character (Interactive)**
    *   A faint outline of the character "茶" will be displayed.
    *   The user will be able to draw on the screen, tracing the strokes of the character. This will be implemented using `CustomPainter` and `GestureDetector`.

3.  **Step 3: Build the Character (Component Selection)**
    *   Question: "Build the hanzi for 'tea'".
    *   The user will be presented with the constituent radicals/parts of the character: `艹`, `人`, `木`.
    *   The user must select them in the correct order to form "茶".

4.  **Step 4: Write from Memory (Interactive)**
    *   A blank canvas will be provided.
    *   The user must write the character "茶" from memory.

### 3. UI Components to be Built

*   **`LessonProgressBar`**: A visual indicator at the top of the screen showing progress through the steps.
*   **`MultipleChoiceWidget`**: A reusable widget for meaning and pronunciation questions.
*   **`CharacterCanvas`**: A custom widget using `CustomPainter` for the tracing and writing exercises.
*   **`CharacterBuilderWidget`**: A widget for the component selection exercise.

### 4. Navigation

*   A new button, "Start Writing Practice," will be added to the `HomePage` to navigate to the `WritingPracticeScreen`.

