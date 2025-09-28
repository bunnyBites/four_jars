# Four Jars

Four Jars is your personal finance sidekick, designed to make budgeting simple, intuitive, and maybe even a little fun. Say goodbye to complicated spreadsheets and hello to a beautifully streamlined approach to managing your money.

## Version 0.1: Foundation & Core Functionality (Completed ✅)

This version represents the completed Minimum Viable Product (MVP) with all essential features in place.

* **Customizable Budget**: Users can set their total monthly income and define custom percentage splits for the four main categories (Needs, Wants, Savings, Investments).
* **Data Persistence**: All user data is saved locally on the device using the **Hive** database.
* **Full CRUD for Data**: Users have complete control to **C**reate, **R**ead, **U**pdate, and **D**elete both transactions and their own custom sub-categories.
* **Insightful Dashboard**: The home screen features a **pie chart** for an at-a-glance spending summary and a 2x2 **grid of "jars"** to track progress.
* **Transaction History**: Users can tap on any category to see a detailed, chronological list of their spending.
* **Clean Architecture**: The project is structured using a **Controller pattern** (`Provider`) that separates the UI from the business logic, making it scalable and easy to maintain.

## Version 0.2: Polish & User Experience(Completed ✅)

This version will focus on refining existing features and improving the overall user experience to make the app feel more professional and intuitive.

* **Empty States**: Implement helpful and visually appealing screens for when lists are empty (e.g., "No transactions yet. Tap '+' to add one!").
* **Enhanced Form Validation**: Display clear, user-facing error messages on all forms if a user enters invalid data.
* **UI Refinements**:
    * Show the **sub-category name** in the transaction history list for more detail.
    * Add an "**Undo**" button to the confirmation message (`SnackBar`) that appears after deleting an item.
* **App Identity**: Design and add a unique **app icon** and a **launch screen (splash screen)**.

## Version 1.0: Advanced Features & Insights

Once the app is polished and robust, this version will introduce powerful new features that provide deeper financial insights and utility.

* **Reports Screen**: A dedicated section with monthly or yearly spending summaries, including more advanced charts and comparisons.
* **Search & Filtering**: A powerful feature allowing users to search for transactions by description or filter their history by a specific date range.
* **Savings Goals**: Allow users to create and track specific financial goals (e.g., "Vacation Fund: ₹50,000") and allocate funds to them.
* **Recurring Transactions**: Add a feature to automatically log recurring expenses like rent, subscriptions, or monthly bills.
