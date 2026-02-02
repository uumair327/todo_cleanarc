# Implementation Plan: Architecture Audit System

## Overview

This implementation plan breaks down the architecture audit system into discrete coding tasks. The system will analyze Flutter code to detect architectural violations, verify Clean Architecture and SOLID principles compliance, and generate comprehensive reports with actionable recommendations.

The implementation follows a bottom-up approach: building core analysis components first, then rule implementations, and finally the reporting and orchestration layers.

## Tasks

- [x] 1. Set up project structure and core data models
  - Create `lib/audit/` directory structure with subdirectories: `models/`, `analyzers/`, `rules/`, `reports/`
  - Define core data models: `SourceFile`, `ClassInfo`, `MethodInfo`, `Dependency`, `Violation`
  - Define enums: `Layer`, `Severity`, `ReportFormat`
  - Set up testing framework with `test` package
  - _Requirements: All requirements (foundation)_

- [x] 2. Implement Code Discovery Module
  - [x] 2.1 Create file discovery implementation
    - Implement `CodeDiscovery` interface with file system traversal
    - Add logic to scan `lib/` directory recursively
    - Filter for `.dart` files only
    - _Requirements: 1.1, 2.1, 3.1_
  
  - [x] 2.2 Implement layer categorization logic
    - Add pattern matching for pages layer: `*/presentation/pages/*`, `*/presentation/screens/*`
    - Add pattern matching for operations layer: `*/domain/usecases/*`, `*/domain/operations/*`
    - Add pattern matching for miscellaneous: `*/utils/*`, `*/helpers/*`, `*/constants/*`
    - Categorize files by detected patterns
    - _Requirements: 1.1, 2.1, 3.1_
  
  - [x] 2.3 Implement feature grouping logic
    - Extract feature name from directory structure (`lib/feature/{name}/`)
    - Group files by feature module
    - Handle core files separately from feature files
    - _Requirements: 8.1_
  
  - [x] 2.4 Write property test for file discovery

    - **Property: File Discovery Completeness**
    - **Validates: Requirements 1.1, 2.1, 3.1**
    - Generate random directory structures and verify all Dart files are discovered
  
  - [ ]* 2.5 Write unit tests for layer categorization
    - Test known file paths are categorized correctly
    - Test edge cases: files in unexpected locations
    - _Requirements: 1.1, 2.1, 3.1_

- [x] 3. Implement Static Analysis Module
  - [x] 3.1 Create AST parser using analyzer package
    - Add `analyzer` package dependency
    - Implement `StaticAnalyzer` interface
    - Parse Dart files into `CompilationUnit` AST
    - Handle parsing errors gracefully
    - _Requirements: 1.1, 2.1, 3.1_
  
  - [x] 3.2 Implement class extraction logic
    - Extract class declarations from AST
    - Capture class name, superclass, interfaces, mixins
    - Extract methods and fields with metadata
    - Track line numbers for violation reporting
    - _Requirements: 5.1, 5.2, 5.3_
  
  - [x] 3.3 Implement dependency extraction logic
    - Extract import statements from AST
    - Classify imports as relative or package imports
    - Determine target layer and feature for each import
    - _Requirements: 1.3, 2.4, 4.1_
  
  - [x] 3.4 Implement widget analysis logic
    - Detect StatelessWidget and StatefulWidget subclasses
    - Identify business logic patterns (database calls, API calls)
    - Calculate widget nesting depth
    - _Requirements: 1.1, 1.4, 6.1_
  
  - [ ]* 3.5 Write property test for AST parsing
    - **Property: AST Parsing Completeness**
    - **Validates: Requirements 1.1, 2.1**
    - Generate random valid Dart code and verify all classes are extracted
  
  - [ ]* 3.6 Write unit tests for dependency extraction
    - Test various import statement formats
    - Test relative vs package imports
    - _Requirements: 1.3, 4.1_

- [ ] 4. Checkpoint - Ensure core analysis components work
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement Dependency Analyzer
  - [ ] 5.1 Create dependency graph builder
    - Build adjacency list representation of dependencies
    - Map each file to its layer
    - Track both direct and transitive dependencies
    - _Requirements: 3.4, 4.1_
  
  - [ ] 5.2 Implement circular dependency detection
    - Use depth-first search to detect cycles
    - Report all files involved in circular dependencies
    - _Requirements: 3.4_
  
  - [ ] 5.3 Implement dependency rule validation
    - Define layer hierarchy: Domain (innermost) -> Operations -> Pages (outermost)
    - Check each dependency follows the inward direction rule
    - Flag violations with source and target information
    - _Requirements: 1.3, 2.4, 4.1, 4.2, 4.5_
  
  - [ ] 5.4 Implement abstraction validation
    - Check that high-level modules depend on interfaces
    - Verify infrastructure implements domain interfaces
    - _Requirements: 4.3, 4.4, 5.4_
  
  - [ ]* 5.5 Write property test for circular dependency detection
    - **Property: Circular Dependency Detection**
    - **Validates: Requirements 3.4**
    - Generate random dependency graphs with known cycles and verify detection
  
  - [ ]* 5.6 Write property test for dependency rule validation
    - **Property: Dependency Rule Enforcement**
    - **Validates: Requirements 1.3, 2.4, 4.1, 4.2, 4.5**
    - Generate random dependencies and verify violations are flagged correctly

- [ ] 6. Implement Rule Engine Foundation
  - [ ] 6.1 Create rule engine interface and base classes
    - Implement `RuleEngine` interface
    - Create abstract `Rule` base class
    - Implement rule registration mechanism
    - Create `AnalysisContext` to pass to rules
    - _Requirements: All requirements_
  
  - [ ] 6.2 Create violation data structure
    - Implement `Violation` class with all required fields
    - Add helper methods for violation creation
    - _Requirements: 7.1, 7.2, 7.3_
  
  - [ ]* 6.3 Write unit tests for rule engine
    - Test rule registration and execution
    - Test violation collection
    - _Requirements: All requirements_

- [ ] 7. Implement Pages Layer Rules
  - [ ] 7.1 Implement PagesContainOnlyPresentationLogicRule
    - Detect database calls, API calls, complex algorithms in pages
    - Flag direct repository usage, HTTP clients
    - _Requirements: 1.1, 1.2, 1.6_
  
  - [ ] 7.2 Implement PagesFollowDependencyRuleRule
    - Check that pages don't import from data or infrastructure layers
    - _Requirements: 1.3_
  
  - [ ] 7.3 Implement WidgetCompositionRule
    - Check widget file size (flag if >300 lines)
    - Check widget nesting depth (flag if >5 levels)
    - _Requirements: 1.4, 6.1_
  
  - [ ] 7.4 Implement StateManagementConsistencyRule
    - Detect state management patterns (BLoC, Provider, setState)
    - Flag mixed patterns within same feature
    - _Requirements: 1.5, 8.1_
  
  - [ ]* 7.5 Write property test for pages layer rules
    - **Property: Layer Separation - Pages**
    - **Validates: Requirements 1.1, 1.2, 1.6**
    - Generate random page components and verify business logic is flagged
  
  - [ ]* 7.6 Write property test for widget composition
    - **Property: Widget Composition Quality**
    - **Validates: Requirements 1.4, 6.1**
    - Generate random widgets with varying sizes and verify violations are detected

- [ ] 8. Implement Operations Layer Rules
  - [ ] 8.1 Implement OperationsSingleResponsibilityRule
    - Analyze method cohesion within operations
    - Flag operations with >5 unrelated methods
    - _Requirements: 2.1, 5.1_
  
  - [ ] 8.2 Implement OperationsDependOnAbstractionsRule
    - Check that operations depend on repository interfaces
    - Flag direct infrastructure dependencies
    - _Requirements: 2.2, 5.4_
  
  - [ ] 8.3 Implement OperationsNoPresentationLogicRule
    - Check for widget imports, BuildContext usage
    - Flag any UI-related code in operations
    - _Requirements: 2.3_
  
  - [ ] 8.4 Implement OperationsInfrastructureViolationRule
    - Detect direct database, HTTP, file system access
    - _Requirements: 2.5_
  
  - [ ] 8.5 Implement OperationsInterfaceSegregationRule
    - Check operation interface method counts
    - Flag interfaces with >10 methods
    - _Requirements: 2.6, 5.3_
  
  - [ ]* 8.6 Write property test for operations layer rules
    - **Property: Layer Separation - Operations**
    - **Validates: Requirements 2.3, 2.5**
    - Generate random operations and verify presentation/infrastructure logic is flagged
  
  - [ ]* 8.7 Write property test for operations abstractions
    - **Property: Operations Depend on Abstractions**
    - **Validates: Requirements 2.2**
    - Generate random operations and verify concrete dependencies are flagged

- [ ] 9. Checkpoint - Ensure layer-specific rules work
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Implement Miscellaneous Components Rules
  - [ ] 10.1 Implement UtilitiesSingleResponsibilityRule
    - Analyze utility class cohesion
    - Flag utilities with unrelated methods
    - _Requirements: 3.1, 5.1_
  
  - [ ] 10.2 Implement HelpersPurityRule
    - Detect side effects in helper functions
    - Check for mutable state, I/O operations
    - Flag impure helpers
    - _Requirements: 3.2_
  
  - [ ] 10.3 Implement ConstantsOrganizationRule
    - Check that constants are grouped by concern
    - Flag mixed constant types in same file
    - _Requirements: 3.3_
  
  - [ ] 10.4 Implement BusinessLogicInUtilitiesRule
    - Detect business logic patterns in utilities
    - Generate recommendations to move to operations layer
    - _Requirements: 3.5_
  
  - [ ]* 10.5 Write property test for helper purity
    - **Property: Helper Function Purity**
    - **Validates: Requirements 3.2**
    - Generate random helper functions and verify side effects are detected
  
  - [ ]* 10.6 Write property test for constants organization
    - **Property: Constants Organization**
    - **Validates: Requirements 3.3**
    - Generate random constants files and verify organization is checked

- [ ] 11. Implement SOLID Principles Rules
  - [ ] 11.1 Implement SingleResponsibilityPrincipleRule
    - Calculate class cohesion metrics
    - Flag classes with >500 lines or low cohesion
    - _Requirements: 5.1_
  
  - [ ] 11.2 Implement LiskovSubstitutionPrincipleRule
    - Analyze method overrides in subclasses
    - Flag methods that throw new exceptions or weaken contracts
    - _Requirements: 5.2_
  
  - [ ] 11.3 Implement InterfaceSegregationPrincipleRule
    - Check interface method counts
    - Flag interfaces with >10 methods
    - _Requirements: 5.3_
  
  - [ ] 11.4 Implement DependencyInversionPrincipleRule
    - Check constructor dependencies
    - Flag concrete class dependencies in high-level modules
    - _Requirements: 5.4_
  
  - [ ] 11.5 Implement OpenClosedPrincipleRule
    - Detect switch statements on types
    - Flag hardcoded implementations without abstraction
    - _Requirements: 5.5_
  
  - [ ]* 11.6 Write property test for single responsibility
    - **Property: Single Responsibility Principle**
    - **Validates: Requirements 2.1, 3.1, 5.1**
    - Generate random classes and verify responsibility violations are detected
  
  - [ ]* 11.7 Write property test for interface segregation
    - **Property: Interface Segregation**
    - **Validates: Requirements 2.6, 5.3**
    - Generate random interfaces and verify bloated interfaces are flagged

- [ ] 12. Implement Best Practices Rules
  - [ ] 12.1 Implement AsyncErrorHandlingRule
    - Check async methods for try-catch blocks
    - Verify resource cleanup (finally blocks, disposal)
    - _Requirements: 6.2_
  
  - [ ] 12.2 Implement FileOrganizationRule
    - Verify files are in correct layer/feature directories
    - _Requirements: 6.3_
  
  - [ ] 12.3 Implement NamingConventionRule
    - Check class names are UpperCamelCase
    - Check method/variable names are lowerCamelCase
    - Check constants are lowerCamelCase or SCREAMING_SNAKE_CASE
    - _Requirements: 6.4_
  
  - [ ] 12.4 Implement TestCoverageRule
    - Check that critical paths have corresponding test files
    - Look for test files matching source files
    - _Requirements: 6.5_
  
  - [ ]* 12.5 Write property test for async error handling
    - **Property: Async Error Handling**
    - **Validates: Requirements 6.2**
    - Generate random async methods and verify error handling is checked
  
  - [ ]* 12.6 Write property test for naming conventions
    - **Property: Naming Convention Compliance**
    - **Validates: Requirements 6.4**
    - Generate random identifiers and verify naming rules are enforced

- [ ] 13. Implement Clean Architecture Rules
  - [ ] 13.1 Implement InfrastructureImplementsInterfacesRule
    - Check infrastructure classes implement domain interfaces
    - _Requirements: 4.3_
  
  - [ ] 13.2 Implement CrossLayerInterfaceRule
    - Verify cross-layer communication uses interfaces
    - _Requirements: 4.4_
  
  - [ ] 13.3 Implement DataTransformationBoundaryRule
    - Check that DTOs are converted at layer boundaries
    - Flag transformations happening within layers
    - _Requirements: 8.3_
  
  - [ ]* 13.4 Write property test for infrastructure interfaces
    - **Property: Infrastructure Implements Domain Interfaces**
    - **Validates: Requirements 4.3, 5.4**
    - Generate random infrastructure classes and verify interface implementation
  
  - [ ]* 13.5 Write property test for data transformations
    - **Property: Data Transformation at Boundaries**
    - **Validates: Requirements 8.3**
    - Generate random data flows and verify transformations occur at boundaries

- [ ] 14. Checkpoint - Ensure all rules are implemented
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 15. Implement Consistency Analysis Rules
  - [ ] 15.1 Implement CrossFeatureConsistencyRule
    - Compare patterns across features
    - Flag inconsistent state management, error handling, DI
    - _Requirements: 8.1, 8.2, 8.4_
  
  - [ ] 15.2 Implement InconsistencyReportingRule
    - Generate reports with examples from each variation
    - _Requirements: 8.5_
  
  - [ ]* 15.3 Write property test for consistency checking
    - **Property: Cross-Component Consistency**
    - **Validates: Requirements 1.5, 8.1, 8.2, 8.4**
    - Generate random feature sets and verify consistency is checked

- [ ] 16. Implement Report Generator
  - [ ] 16.1 Create report data structures
    - Implement `AuditReport`, `ProjectSummary`, `HealthScore` classes
    - Implement `Recommendation` class with prioritization
    - _Requirements: 7.4, 7.5, 7.6_
  
  - [ ] 16.2 Implement violation aggregation logic
    - Group violations by category and severity
    - Calculate violation statistics
    - _Requirements: 7.4_
  
  - [ ] 16.3 Implement health score calculation
    - Calculate scores based on violation counts and severity
    - Assign letter grades (A-F)
    - Calculate separate scores for Clean Architecture, SOLID, best practices
    - _Requirements: 7.5_
  
  - [ ] 16.4 Implement recommendation prioritization
    - Prioritize by impact on testability and maintainability
    - Group related violations into single recommendations
    - _Requirements: 7.6_
  
  - [ ] 16.5 Implement Markdown report generation
    - Generate structured Markdown with sections
    - Include code snippets where helpful
    - Format violations in readable tables
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [ ] 16.6 Implement JSON report generation
    - Generate machine-readable JSON output
    - Include all violation details and metadata
    - _Requirements: 7.1, 7.2, 7.3_
  
  - [ ]* 16.7 Write property test for report completeness
    - **Property: Report Structure Completeness**
    - **Validates: Requirements 7.4, 7.5, 7.6**
    - Generate random violation sets and verify reports include all required sections
  
  - [ ]* 16.8 Write property test for violation reporting
    - **Property: Complete Violation Reports**
    - **Validates: Requirements 7.1, 7.2, 7.3**
    - Generate random violations and verify reports include file, line, explanation, recommendations
  
  - [ ]* 16.9 Write unit tests for report generation
    - Test Markdown formatting
    - Test JSON structure
    - Test health score calculation
    - _Requirements: 7.4, 7.5_

- [ ] 17. Implement Main Orchestration
  - [ ] 17.1 Create main audit orchestrator
    - Coordinate all analysis stages
    - Handle errors gracefully and continue analysis
    - Collect partial results on failures
    - _Requirements: All requirements_
  
  - [ ] 17.2 Implement CLI interface
    - Add command-line argument parsing
    - Support options: project path, output format, output path
    - Display progress during analysis
    - _Requirements: All requirements_
  
  - [ ] 17.3 Add error handling and recovery
    - Handle file system errors gracefully
    - Handle parsing errors and continue
    - Report errors in separate section
    - _Requirements: All requirements_
  
  - [ ]* 17.4 Write integration tests
    - Test full audit pipeline on sample projects
    - Verify end-to-end functionality
    - _Requirements: All requirements_

- [ ] 18. Implement Performance Optimizations
  - [ ] 18.1 Add file caching
    - Cache parsed ASTs to avoid re-parsing
    - Implement cache invalidation strategy
    - _Requirements: All requirements (performance)_
  
  - [ ] 18.2 Add parallel processing
    - Analyze independent files concurrently
    - Use isolates for CPU-intensive analysis
    - _Requirements: All requirements (performance)_
  
  - [ ]* 18.3 Write performance tests
    - Test analysis speed on large codebases
    - Verify memory usage stays reasonable
    - _Requirements: All requirements (performance)_

- [ ] 19. Final checkpoint and documentation
  - [ ] 19.1 Ensure all tests pass
    - Run full test suite including property-based tests
    - Fix any failing tests
    - _Requirements: All requirements_
  
  - [ ] 19.2 Create usage documentation
    - Write README with installation and usage instructions
    - Document CLI options and configuration
    - Provide example outputs
    - _Requirements: All requirements_
  
  - [ ] 19.3 Create rule documentation
    - Document each rule with examples
    - Explain rationale for each rule
    - Provide remediation guidance
    - _Requirements: All requirements_

- [ ] 20. Final integration test and validation
  - Run complete audit on the Flutter todo app itself
  - Verify all violations are detected correctly
  - Validate report quality and recommendations
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation throughout implementation
- Property tests validate universal correctness properties with 100+ iterations
- Unit tests validate specific examples and edge cases
- The implementation follows a bottom-up approach: core components first, then rules, then orchestration
- Error handling is built in at each layer to ensure robust analysis
- Performance optimizations are implemented after core functionality is complete
