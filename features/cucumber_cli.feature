Feature: Cucumber command line
  In order to write better software
  Developers should be able to execute requirements as tests

  Scenario: Run single scenario with missing step definition
    When I run cucumber -q features/sample.feature:5
    Then it should pass with      
      """
      # Feature comment
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

      1 scenario (1 undefined)
      1 step (1 undefined)

      """

  Scenario: Fail with --strict
    When I run cucumber -q features/sample.feature:5 --strict
    Then it should fail with
      """
      # Feature comment
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing
            Undefined step: "missing" (Cucumber::Undefined)
            features/sample.feature:7:in `Given missing'

      1 scenario (1 undefined)
      1 step (1 undefined)

      """

  Scenario: Succeed with --strict
    When I run cucumber -q features/sample.feature:10 --strict
    Then it should pass with
    """
    # Feature comment
    @one
    Feature: Sample

      # Scenario comment
      @three
      Scenario: Passing
        Given passing
          | a | b |
          | c | d |

    1 scenario (1 passed)
    1 step (1 passed)

    """

  @mri186
  Scenario: Specify 2 line numbers where one is a tag
    When I run cucumber -q features/sample.feature:5:16
    Then it should fail with
      """
      # Feature comment
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

        @four
        Scenario: Failing
          Given failing
            \"\"\"
            hello
            \"\"\"
            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:2:in `flunker'
            ./features/step_definitions/sample_steps.rb:9:in `/^failing$/'
            features/sample.feature:18:in `Given failing'
      
      Failing Scenarios:
      cucumber features/sample.feature:17 # Scenario: Failing
      
      2 scenarios (1 failed, 1 undefined)
      2 steps (1 failed, 1 undefined)

      """

  Scenario: Require missing step definition from elsewhere
    When I run cucumber -q -r ../../features/step_definitions/extra_steps.rb features/sample.feature:5
    Then it should pass with
      """
      # Feature comment
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

      1 scenario (1 passed)
      1 step (1 passed)

      """

  Scenario: Specify the line number of a row
    When I run cucumber -q features/sample.feature:12
    Then it should pass with
      """
      # Feature comment
      @one
      Feature: Sample

        # Scenario comment
        @three
        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

      1 scenario (1 passed)
      1 step (1 passed)

      """

  @mri186
  Scenario: Run all with progress formatter
    When I run cucumber -q --format progress features/sample.feature
    Then it should fail with
      """
      U.F

      (::) failed steps (::)

      FAIL (RuntimeError)
      ./features/step_definitions/sample_steps.rb:2:in `flunker'
      ./features/step_definitions/sample_steps.rb:9:in `/^failing$/'
      features/sample.feature:18:in `Given failing'

      Failing Scenarios:
      cucumber features/sample.feature:17 # Scenario: Failing

      3 scenarios (1 failed, 1 undefined, 1 passed)
      3 steps (1 failed, 1 undefined, 1 passed)

      """

  Scenario: Run Norwegian
    Given I am in i18n/no
    When I run cucumber -q --language no features
    Then STDERR should be empty
    Then it should pass with
      """
      # language: no
      Egenskap: Summering
        For å slippe å gjøre dumme feil
        Som en regnskapsfører
        Vil jeg kunne legge sammen

        Scenario: to tall
          Gitt at jeg har tastet inn 5
          Og at jeg har tastet inn 7
          Når jeg summerer
          Så skal resultatet være 12

        @iterasjon3
        Scenario: tre tall
          Gitt at jeg har tastet inn 5
          Og at jeg har tastet inn 7
          Og at jeg har tastet inn 1
          Når jeg summerer
          Så skal resultatet være 13

      2 scenarios (2 passed)
      9 steps (9 passed)

      """

  Scenario: --dry-run
    When I run cucumber --dry-run --no-snippets features/*.feature --tags ~@lots
    Then it should pass with
      """
      Feature: Calling undefined step

        Scenario: Call directly
          Given a step definition that calls an undefined step

        Scenario: Call via another
          Given call step "a step definition that calls an undefined step"

      Feature: Failing expectation

        Scenario: Failing expectation
          Given failing expectation

      Feature: Lots of undefined

        Scenario: Implement me
          Given it snows in Sahara
          Given it's 40 degrees in Norway
          And it's 40 degrees in Norway
          When I stop procrastinating
          And there is world peace

      Feature: multiline

        Background: I'm a multiline name
          which goes on and on and on for three lines
          yawn
          Given passing without a table

        Scenario: I'm a multiline name
          which goes on and on and on for three lines
          yawn
          Given passing without a table

        Scenario Outline: I'm a multiline name
          which goes on and on and on for three lines
          yawn
          Given <state> without a table

          Examples: 
            | state   |
            | passing |
    
        Scenario Outline: name
          Given <state> without a table

          Examples: I'm a multiline name
            which goes on and on and on for three lines
            yawn
            | state   |
            | passing |

      Feature: Outline Sample

        Scenario: I have no steps

        Scenario Outline: Test state
          Given <state> without a table
          Given <other_state> without a table

          Examples: Rainbow colours
            | state   | other_state |
            | missing | passing     |
            | passing | passing     |
            | failing | passing     |

          Examples: Only passing
            | state   | other_state |
            | passing | passing     |

      # Feature comment
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

        # Scenario comment
        @three
        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

        @four
        Scenario: Failing
          Given failing
            \"\"\"
            hello
            \"\"\"

      Feature: search examples

        Background: Hantu Pisang background match
          Given passing without a table

        Scenario: should match Hantu Pisang
          Given passing without a table

        Scenario: Ignore me
          Given failing without a table

        Scenario Outline: Ignore me
          Given <state> without a table

          Examples: 
            | state   |
            | failing |

        Scenario Outline: Hantu Pisang match
          Given <state> without a table

          Examples: 
            | state   |
            | passing |

        Scenario Outline: no match in name but in examples
          Given <state> without a table

          Examples: Hantu Pisang
            | state   |
            | passing |

          Examples: Ignore me
            | state   |
            | failing |

      @sample_one
      Feature: Tag samples

        @sample_two @sample_four
        Scenario: Passing
          Given missing

        @sample_three
        Scenario Outline: 
          Given <state>

          Examples: 
            | state   |
            | missing |

        @sample_three @sample_four
        Scenario: Skipped
          Given missing

      Feature: undefined multiline args
      
        Scenario: pystring
          Given a pystring
            \"\"\"
              example
            \"\"\"
      
        Scenario: table
          Given a table
            | table   |
            | example |

      26 scenarios (17 skipped, 8 undefined, 1 passed)
      42 steps (30 skipped, 12 undefined)

      """

  Scenario: Multiple formatters and outputs
    When I run cucumber --format progress --out tmp/progress.txt --format pretty --out tmp/pretty.txt  --dry-run features/lots_of_undefined.feature
    And "examples/self_test/tmp/progress.txt" should contain
      """
      UUUUU

      1 scenario (1 undefined)
      5 steps (5 undefined)

      """
    And "examples/self_test/tmp/pretty.txt" should contain
      """
      Feature: Lots of undefined

        Scenario: Implement me
          Given it snows in Sahara
          Given it's 40 degrees in Norway
          And it's 40 degrees in Norway
          When I stop procrastinating
          And there is world peace
      
      1 scenario (1 undefined)
      5 steps (5 undefined)

      """

  Scenario: Run feature elements which matches a name using --name
    When I run cucumber --name Pisang -q features/
    Then it should pass with
      """
      Feature: search examples

        Background: Hantu Pisang background match
          Given passing without a table

        Scenario: should match Hantu Pisang
          Given passing without a table

        Scenario Outline: Hantu Pisang match
          Given <state> without a table

          Examples: 
            | state   |
            | passing |

        Scenario Outline: no match in name but in examples
          Given <state> without a table

          Examples: Hantu Pisang
            | state   |
            | passing |

      3 scenarios (3 passed)
      6 steps (6 passed)

      """

  Scenario: Run a single background which matches a name using --name (Useful if there is an error in it)
    When I run cucumber --name 'Hantu Pisang background' -q features/
    Then it should pass with
      """
      Feature: search examples

        Background: Hantu Pisang background match
          Given passing without a table

      0 scenarios
      1 step (1 passed)

      """


  Scenario: Run with a tag that exists on 2 scenarios
    When I run cucumber -q features --tags three
    Then it should pass with
      """
      # Feature comment
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

        # Scenario comment
        @three
        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

      2 scenarios (1 undefined, 1 passed)
      2 steps (1 undefined, 1 passed)

      """

  @mri186
  Scenario: Run with a tag that exists on 1 feature
    When I run cucumber -q features --tags one
    Then it should fail with
      """
      # Feature comment
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

        # Scenario comment
        @three
        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

        @four
        Scenario: Failing
          Given failing
            \"\"\"
            hello
            \"\"\"
            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:2:in `flunker'
            ./features/step_definitions/sample_steps.rb:9:in `/^failing$/'
            features/sample.feature:18:in `Given failing'

      Failing Scenarios:
      cucumber features/sample.feature:17 # Scenario: Failing

      3 scenarios (1 failed, 1 undefined, 1 passed)
      3 steps (1 failed, 1 undefined, 1 passed)

      """

  Scenario: Run with a negative tag
    When I run cucumber -q features/sample.feature --dry-run -t ~four
    Then it should pass with
      """
      # Feature comment
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

        # Scenario comment
        @three
        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

      2 scenarios (1 skipped, 1 undefined)
      2 steps (1 skipped, 1 undefined)

      """

  Scenario: Run with limited tag number
     When I run cucumber -q features/tags_sample.feature --dry-run -t sample_three:1
     Then it should fail with      
     """
     @sample_one
     Feature: Tag samples

       @sample_three
       Scenario Outline: 
         Given <state>

         Examples: 
           | state   |
           | missing |

       @sample_three @sample_four
       Scenario: Skipped
         Given missing

     2 scenarios (2 undefined)
     2 steps (2 undefined)

     Failed due to exceeding the tag limit
     @sample_three occurred:2 limit:1
       features/tags_sample.feature:9
       features/tags_sample.feature:16

     """

   Scenario: Run with a feature tag which has a limit
     When I run cucumber -q features/tags_sample.feature --dry-run -t sample_one:1
     Then it should fail with
     """
     @sample_one
     Feature: Tag samples

       @sample_two @sample_four
       Scenario: Passing
         Given missing

       @sample_three
       Scenario Outline: 
         Given <state>

         Examples: 
           | state   |
           | missing |

       @sample_three @sample_four
       Scenario: Skipped
         Given missing

     3 scenarios (3 undefined)
     3 steps (3 undefined)

     Failed due to exceeding the tag limit
     @sample_one occurred:3 limit:1
       features/tags_sample.feature:5
       features/tags_sample.feature:9
       features/tags_sample.feature:16

     """

  Scenario: Reformat files with --autoformat
    When I run cucumber --autoformat tmp/formatted features
    Then "examples/self_test/tmp/formatted/features/sample.feature" should contain
      """
      # Feature comment
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

        # Scenario comment
        @three
        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

        @four
        Scenario: Failing
          Given failing
            \"\"\"
            hello
            \"\"\"


      """

  Scenario: Run feature elements which match a name using -n
    When I run cucumber -n Pisang -q features/
    Then it should pass with
      """
      Feature: search examples

        Background: Hantu Pisang background match
          Given passing without a table

        Scenario: should match Hantu Pisang
          Given passing without a table

        Scenario Outline: Hantu Pisang match
          Given <state> without a table

          Examples: 
            | state   |
            | passing |

        Scenario Outline: no match in name but in examples
          Given <state> without a table

          Examples: Hantu Pisang
            | state   |
            | passing |

      3 scenarios (3 passed)
      6 steps (6 passed)

      """
