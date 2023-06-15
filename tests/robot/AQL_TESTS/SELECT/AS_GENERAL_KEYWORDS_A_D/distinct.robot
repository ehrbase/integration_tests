*** Settings ***
Documentation   CHECK SELECT DISTINCT
...             - Covers: https://github.com/ehrbase/AQL_Test_CASES/blob/main/SELECT_TEST_SUIT.md#distinct--general-keywords-a-d
Resource        ../../../_resources/keywords/aql_keywords.robot


*** Test Cases ***
Test Distinct: SELECT e/ehr_id/value AS full FROM EHR e contains COMPOSITIONS C
    [Documentation]     - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create 2x Compositions
    ...         - Send AQL 'SELECT e/ehr_id/value AS full FROM EHR e contains COMPOSITIONS C'
    ...         - Check that result contains 2 rows
    ...         - Check if actual response == expected response
    #[Tags]      not-ready
    [Setup]     Precondition
    ${query1}    Set Variable    SELECT e/ehr_id/value AS full FROM EHR e contains COMPOSITIONS C
    Set AQL And Execute Ad Hoc Query        ${query1}
    ${expected_result}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/select/distinct_2_rows.json
    Log     Add test data once 200 is returned. File: ${expected_result}
    ${exclude_paths}    Create List    root['rows'][0][0]['uid']
    Length Should Be    ${resp_body['rows']}     2
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_result}      exclude_paths=${exclude_paths}
    #Log To Console    \n\n${diff}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!

Test Distinct: SELECT DISTINCT e/ehr_id/value AS full FROM EHR e contains COMPOSITIONS C
    [Documentation]     \n
    ...         - Send AQL 'SELECT DISTINCT e/ehr_id/value AS full FROM EHR e contains COMPOSITIONS C'
    ...         - Check that result contains 1 row
    ...         - Check if actual response == expected response
    ...         - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
    #[Tags]      not-ready
    ${query2}    Set Variable    SELECT DISTINCT e/ehr_id/value AS full FROM EHR e contains COMPOSITIONS C
    Set AQL And Execute Ad Hoc Query        ${query2}
    ${expected_result}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/select/distinct_1_row.json
    Log     Add test data once 200 is returned. File: ${expected_result}    console=yes
    ${exclude_paths}    Create List    root['rows'][0][0]['uid']
    Length Should Be    ${resp_body['rows']}     1
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_result}      exclude_paths=${exclude_paths}
    #Log To Console    \n\n${diff}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Admin Delete EHR For AQL


*** Keywords ***
Precondition
    Upload OPT For AQL      aql-conformance-ehrbase.org.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      aql-conformance-ehrbase.org.v0_contains.json
    Set Test Variable       ${compo_uid_1}      ${composition_short_uid}
    Commit Composition For AQL      aql-conformance-ehrbase.org.v0_contains.json
    Set Test Variable       ${compo_uid_2}      ${composition_short_uid}