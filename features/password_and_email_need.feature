@pivotal_3773892

Feature:  As a social butterfly/little miss bashful I have to fill in email/password if fill in username
  In order to properly fill forms
  As user
  I want validate forms input
  
  Scenario: As a social butterfly I don't have to fill in email if I don't fill in username
    When I go to the "take the test" page

    And I fill in "Join us. Choose a username for your Mindapples account.(careful, you can only choose once)" with "banana_man"

    And I check "person_policy_checked"
    And I press "Submit"
    Then I should not see "Here are their mindapples"

  Scenario: As a social butterfl I must fill in email/password confirmation if I fill in username
    When I go to the "take the test" page

    And I fill in "Join us. Choose a username for your Mindapples account.(careful, you can only choose once)" with "banana_man"
    And I fill in "person[password]" with "secretsuper"
    And I fill in "person[password_confirmation]" with "secretsuper"
    And I check "person_policy_checked"
    And I press "Submit"
    Then I should not see "Here are their mindapples"

  Scenario: As a social butterfly/little miss bashful I must fill in email/password confirmation if I fill in username
    When I go to the "take the test" page

    And I fill in "Join us. Choose a username for your Mindapples account.(careful, you can only choose once)" with "banana_man"
    And I fill in "Don't go! Leave your e-mail" with "andy@example.com"
    And I check "person_policy_checked"
    And I press "Submit"
    Then I should not see "Here are their mindapples"

  Scenario: As a little miss bashful I don't have to fill in email if I don't fill in username
    When I go to the homepage
    And I fill in "person[mindapples_attributes][0][suggestion]" with "Wrestling with bears"
    And I fill in "person[mindapples_attributes][1][suggestion]" with "Being in nature"
    And I fill in "person[mindapples_attributes][2][suggestion]" with "Interesting conversation"
    And I fill in "person[mindapples_attributes][4][suggestion]" with "Tidying and filing"
    And I press "Submit"
    And the "Yes yes, of course I accept the Terms & Conditions" checkbox should not be checked

    And I fill in "Join us. Choose a username for your Mindapples account.(careful, you can only choose once)" with "banana_man"
    And I check "person_policy_checked"
    And I press "Submit"
    Then I should not see "Here are their mindapples"

  Scenario: As a little miss bashful I must fill in email/password confirmation if I fill in username
    When I go to the homepage
    And I fill in "person[mindapples_attributes][0][suggestion]" with "Wrestling with bears"
    And I fill in "person[mindapples_attributes][1][suggestion]" with "Being in nature"
    And I fill in "person[mindapples_attributes][2][suggestion]" with "Interesting conversation"
    And I fill in "person[mindapples_attributes][4][suggestion]" with "Tidying and filing"
    And I press "Submit"

    And I fill in "Join us. Choose a username for your Mindapples account.(careful, you can only choose once)" with "banana_man"
    And I fill in "person[password]" with "secretsuper"
    And I fill in "person[password_confirmation]" with "secretsuper"
    And I check "person_policy_checked"
    And I press "Submit"
    Then I should not see "Here are their mindapples"
    And I should see "We need your email address to create your account."

  Scenario: I'm not able save blank password on edit page if I fill in username
    When I go to the homepage
    And I fill in "person[mindapples_attributes][0][suggestion]" with "Wrestling with bears"
    And I fill in "person[mindapples_attributes][1][suggestion]" with "Being in nature"
    And I fill in "person[mindapples_attributes][2][suggestion]" with "Interesting conversation"
    And I fill in "person[mindapples_attributes][4][suggestion]" with "Tidying and filing"
    And I press "Submit"

    And I fill in "Join us. Choose a username for your Mindapples account.(careful, you can only choose once)" with "banana_man"
    And I fill in "person[password]" with ""
    And I fill in "person[password_confirmation]" with ""
    And I fill in "Don't go! Leave your e-mail" with "andy@example.com"
    And I check "person_policy_checked"
    And I press "Submit"
    Then I should see "Please choose a valid password (minimum is 4 characters)"
    Then I should not see "Here are their mindapples"

  Scenario: I'm not able save already existed login
    Given person exists with login: "banana_man"
    When I go to the homepage
    And I fill in "person[mindapples_attributes][0][suggestion]" with "Wrestling with bears"
    And I press "Submit"

    And I fill in "Join us. Choose a username for your Mindapples account.(careful, you can only choose once)" with "banana_man"
    And I fill in "person[password]" with "supersecret"
    And I fill in "person[password_confirmation]" with "supersecret"
    And I fill in "Don't go! Leave your e-mail" with "andy@example.com"
    And I check "person_policy_checked"
    And I press "Submit"
    Then I should see "That username has already been taken. Please choose again."
    Then I should not see "Here are their mindapples"

  Scenario: Person try log in with wrong login or password
    Given I have a personal page
    And my login is "gandy"
    And my password is "sosocial"
    And my braindump is "I love Mindapples"
    And I go to the login page
    And I fill in "Login" with "gandy"
    And I fill in "Password" with "antisosocial"
    And I press "Log in"
    Then I should see "Sorry, we don't recognise that username and password combination. Please try again."    