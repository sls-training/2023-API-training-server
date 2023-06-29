D = Steep::Diagnostic

target :app do
  signature 'sig'

  check 'app'

  ignore 'app/resources'

  configure_code_diagnostics do |hash|
    hash[D::Ruby::ArgumentTypeMismatch] = :warning
    hash[D::Ruby::BlockBodyTypeMismatch] = :warning
    hash[D::Ruby::BlockTypeMismatch] = :warning
    hash[D::Ruby::BreakTypeMismatch] = :warning
    hash[D::Ruby::DifferentMethodParameterKind] = :warning
    hash[D::Ruby::ElseOnExhaustiveCase] = :warning
    hash[D::Ruby::FallbackAny] = :warning
    hash[D::Ruby::FalseAssertion] = :warning
    hash[D::Ruby::ImplicitBreakValueMismatch] = :warning
    hash[D::Ruby::IncompatibleAnnotation] = :warning
    hash[D::Ruby::IncompatibleArgumentForwarding] = :warning
    hash[D::Ruby::IncompatibleAssignment] = :warning
    hash[D::Ruby::IncompatibleMethodTypeAnnotation] = :warning
    hash[D::Ruby::IncompatibleTypeCase] = :warning
    hash[D::Ruby::InsufficientKeywordArguments] = :warning
    hash[D::Ruby::InsufficientPositionalArguments] = :warning
    hash[D::Ruby::InsufficientTypeArgument] = :warning
    hash[D::Ruby::MethodArityMismatch] = :warning
    hash[D::Ruby::MethodBodyTypeMismatch] = :warning
    hash[D::Ruby::MethodDefinitionMissing] = :warning
    hash[D::Ruby::MethodParameterMismatch] = :warning
    hash[D::Ruby::MethodReturnTypeAnnotationMismatch] = :warning
    hash[D::Ruby::MultipleAssignmentConversionError] = :warning
    hash[D::Ruby::NoMethod] = :warning
    hash[D::Ruby::ProcTypeExpected] = :warning
    hash[D::Ruby::RequiredBlockMissing] = :warning
    hash[D::Ruby::ReturnTypeMismatch] = :warning
    hash[D::Ruby::SyntaxError] = :warning
    hash[D::Ruby::TypeArgumentMismatchError] = :warning
    hash[D::Ruby::UnexpectedBlockGiven] = :warning
    hash[D::Ruby::UnexpectedDynamicMethod] = :warning
    hash[D::Ruby::UnexpectedError] = :warning
    hash[D::Ruby::UnexpectedJumpValue] = :warning
    hash[D::Ruby::UnexpectedJump] = :warning
    hash[D::Ruby::UnexpectedKeywordArgument] = :warning
    hash[D::Ruby::UnexpectedPositionalArgument] = :warning
    hash[D::Ruby::UnexpectedSplat] = :warning
    hash[D::Ruby::UnexpectedSuper] = :warning
    hash[D::Ruby::UnexpectedTypeArgument] = :warning
    hash[D::Ruby::UnexpectedYield] = :warning
    hash[D::Ruby::UnknownConstant] = :warning
    hash[D::Ruby::UnknownGlobalVariable] = :warning
    hash[D::Ruby::UnknownInstanceVariable] = :warning
    hash[D::Ruby::UnresolvedOverloading] = :warning
    hash[D::Ruby::UnsatisfiableConstraint] = :warning
    hash[D::Ruby::UnsupportedSyntax] = :warning

    # NOTE: These diagnostics are implemented on HEAD at 2023-06-29.
    # hash[D::Ruby::ProcHintIgnored] = :warning
    # hash[D::Ruby::SetterBodyTypeMismatch] = :warning
    # hash[D::Ruby::SetterReturnTypeMismatch] = :warning
  end
end
