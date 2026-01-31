/// Represents the architectural layer of a source file
enum Layer {
  /// Presentation layer (screens, pages, widgets)
  pages,
  
  /// Use cases and business logic layer
  operations,
  
  /// Utilities, helpers, constants, and supporting code
  miscellaneous,
  
  /// Domain layer (entities, value objects, repository interfaces)
  domain,
  
  /// Infrastructure layer (implementations, external services)
  infrastructure,
}
