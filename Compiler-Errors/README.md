Remix Solidity compiler 0.4.12+commit.194ff033 throws an error when trying to compile this contracts.


```Internal exception in StandardCompiler::compileInternal: /src/libsolidity/ast/ASTJsonConverter.cpp(791): Throw in function string dev::solidity::ASTJsonConverter::functionCallKind(dev::solidity::FunctionCallKind)
Dynamic exception type: N5boost16exception_detail10clone_implIN3dev8solidity21InternalCompilerErrorEEE
std::exception::what: std::exception
[PN3dev11tag_commentE] = Unknown kind of function call .
```


TESTED:

Remix Solidity compiler 0.4.12-nightly.2017.6.23+commit.793f05fa compiles without errors.

0.4.12-nightly.2017.6.25+commit.29b8cdb5 throws an error:

```
Internal exception in StandardCompiler::compileInternal: /src/libsolidity/interface/CompilerStack.cpp(511): Throw in function const dev::solidity::SourceUnit &dev::solidity::CompilerStack::ast(const string &) const
Dynamic exception type: N5boost16exception_detail10clone_implIN3dev8solidity13CompilerErrorEEE
std::exception::what: std::exception
[PN3dev11tag_commentE] = Parsing was not successful.
```

0.4.12-nightly.2017.6.26+commit.f8794892 throws a similar error ^ from the previous one.

0.4.12-nightly.2017.6.27+commit.bc31d496 throws a similar error ^ from the previous one.


0.4.12-nightly.2017.6.28+commit.e19c4125 throws following error:

```
Internal exception in StandardCompiler::compileInternal: /src/libsolidity/interface/CompilerStack.cpp(496): Throw in function const dev::solidity::SourceUnit &dev::solidity::CompilerStack::ast(const string &) const
Dynamic exception type: N5boost16exception_detail10clone_implIN3dev8solidity13CompilerErrorEEE
std::exception::what: std::exception
[PN3dev11tag_commentE] = Parsing was not successful.
```


0.4.12-nightly.2017.6.29+commit.f5372cda throws a similar error ^ from the previous one.

0.4.12-nightly.2017.6.30+commit.568e7520 throws a similar error ^ from the previous one.

0.4.12-nightly.2017.7.1+commit.06f8949f  throws a similar error ^ from the previous one.

0.4.12-nightly.2017.7.3+commit.0c7530a8  throws a similar error ^ from the previous one.


0.4.12+commit.194ff033  throws the following error:

```
Internal compiler error (/src/libsolidity/codegen/CompilerContext.cpp:127): Variable already present
```
