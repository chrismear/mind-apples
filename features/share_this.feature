@pivotal_3772738

Feature: As a Social Butterfly I would like to invite others to MA by posting to facebook/twitter
  In order to let visitors share content through social network sites
  As a user
  I want a share this link in the ____ page

  Background:
    Given I have a personal page
    And my login is "visible_ninja"
    And my password is "cybersecret"
    And I log in

  Scenario: I can share something through facebook
    When I go to "/person/visible_ninja"
    And I should see a ShareThis facebook link
    Then I follow "addthis_button_twitter"
    And I should see "Mindapples is group of volunteers"

  Scenario: I can share something through twitter
    When I go to "/person/visible_ninja"
    And I should see a ShareThis twitter link
