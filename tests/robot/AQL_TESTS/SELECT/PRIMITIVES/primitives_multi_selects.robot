*** Settings ***
Documentation   CHECK Primitives: Primitives multi selects
...             - Covers the following:
...             - https://github.com/ehrbase/AQL_Test_CASES/blob/main/SELECT_TEST_SUIT.md#multi-selects

Resource        ../../../_resources/keywords/aql_keywords.robot


*** Test Cases ***
SELECT e/ehr_id/value, c/uid/value, o/uid/value, p/time/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o CONTAINS POINT_EVENT p
    #[Tags]      not-ready
    [Documentation]     - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create 2 Compositions; 4. Save their composition_uid value
    ...         - Send AQL 'SELECT e/ehr_id/value, c/uid/value, o/uid/value, p/time/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o CONTAINS POINT_EVENT p'
    ...         - Check if actual response == expected response (in any order)
    ...         - Check that result contains 8 rows
    ...         - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
    #[Tags]      not-ready
    [Setup]     Precondition
    ${query}    Set Variable    SELECT e/ehr_id/value, c/uid/value, o/uid/value, p/time/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o CONTAINS POINT_EVENT p
    Set AQL And Execute Ad Hoc Query        ${query}
    ${expected_result}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/select/primitives_multi_selects_expected.json
    Length Should Be    ${resp_body['rows']}    8
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_result}      ignore_order=${TRUE}    ignore_string_case=${TRUE}
    #Log To Console    \n\n${diff}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Admin Delete EHR For AQL


*** Keywords ***
Precondition
    Upload OPT For AQL      aql-conformance-ehrbase.org.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      aql-conformance-ehrbase.org.v0_contains.json
    Set Suite Variable      ${c_uid1}      ${composition_short_uid}
    Commit Composition For AQL      aql-conformance-ehrbase.org.v0_contains.json
    Set Suite Variable      ${c_uid2}      ${composition_short_uid}