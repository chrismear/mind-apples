@committed

Feature: Setting login
  In order to have a more personalized page
  As a social butterfly
  I want to pick my nickname for my page

  Scenario: Picking a nickname from the "take the test" page
    When I go to the "take the test" page
    And I fill in "person[mindapples_attributes][0][suggestion]" with "Playing the piano"
    And I fill in "Join us. Choose a username" with "spotty"
    And I fill in "Don't go! Leave your e-mail and we'll send you occasional messages. (never made public)" with "apple@mind.com"
    And I fill in "person_password" with "bigsecret"
    And I fill in "person_password_confirmation" with "bigsecret"
    And I check "person_policy_checked"
    And I press "Submit"
    And I follow "Edit"
    Then I should not see "Join us. Choose a username to claim your page"
    # Then I should not see a "person[login]" text field
    And I should be on "/person/spotty/edit"

  Scenario: Trying to set login to a value that starts with autogenerated marker from the "take the test" page
    When I go to the "take the test" page
    And I fill in "person[mindapples_attributes][0][suggestion]" with "Playing the piano"
    And I fill in "Join us. Choose a username" with "autogen_bla"
    And I press "Submit"
    Then I should see "Login can not start with 'autogen_'"
    And I should see a "person[login]" text field

  Scenario: Trying to set login to a value that starts with an underscore from the "take the test" page
    When I go to the "take the test" page
    And I fill in "person[mindapples_attributes][0][suggestion]" with "Playing the piano"
    And I fill in "Join us. Choose a username" with "_pluk"
    And I press "Submit"
    Then I should see "Login can not begin with an underscore"
    And I should see a "person[login]" text field
