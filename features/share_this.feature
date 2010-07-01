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
    And I should see "addthis_button_twitter" image link with "http://api.addthis.com/oexchange/0.8/forward/twitter/offer?url=http://mindapples.staging.tomtenthij.co.uk&title=cooolstuf is minapple" url

  Scenario: I can share something through twitter
    When I go to "/person/visible_ninja"
    And I should see "addthis_button_facebook" image link with "http://api.addthis.com/oexchange/0.8/forward/facebook/offer?url=http://mindapples.staging.tomtenthij.co.uk&title=cooolstuf is minapple" url
