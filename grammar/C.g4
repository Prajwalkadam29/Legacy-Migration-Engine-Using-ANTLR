grammar C;

// Parser Rules
compilationUnit
    : translationUnit? EOF
    ;

translationUnit
    : externalDeclaration+
    ;

externalDeclaration
    : functionDefinition
    | declaration
    | ';'
    ;

functionDefinition
    : declarationSpecifiers? declarator declarationList? compoundStatement
    ;

declarationList
    : declaration+
    ;

declaration
    : declarationSpecifiers initDeclaratorList? ';'
    ;

declarationSpecifiers
    : declarationSpecifier+
    ;

declarationSpecifier
    : storageClassSpecifier
    | typeSpecifier
    | typeQualifier
    ;

initDeclaratorList
    : initDeclarator (',' initDeclarator)*
    ;

initDeclarator
    : declarator ('=' initializer)?
    ;

storageClassSpecifier
    : 'typedef'
    | 'extern'
    | 'static'
    | 'auto'
    | 'register'
    ;

typeSpecifier
    : 'void'
    | 'char'
    | 'short'
    | 'int'
    | 'long'
    | 'float'
    | 'double'
    | 'signed'
    | 'unsigned'
    | structOrUnionSpecifier
    | enumSpecifier
    | typedefName
    ;

structOrUnionSpecifier
    : structOrUnion Identifier? '{' structDeclarationList '}'
    | structOrUnion Identifier
    ;

structOrUnion
    : 'struct'
    | 'union'
    ;

structDeclarationList
    : structDeclaration+
    ;

structDeclaration
    : specifierQualifierList structDeclaratorList ';'
    ;

specifierQualifierList
    : (typeSpecifier | typeQualifier)+
    ;

structDeclaratorList
    : structDeclarator (',' structDeclarator)*
    ;

structDeclarator
    : declarator
    | declarator? ':' constantExpression
    ;

enumSpecifier
    : 'enum' Identifier? '{' enumeratorList ','? '}'
    | 'enum' Identifier
    ;

enumeratorList
    : enumerator (',' enumerator)*
    ;

enumerator
    : Identifier ('=' constantExpression)?
    ;

typeQualifier
    : 'const'
    | 'volatile'
    ;

declarator
    : pointer? directDeclarator
    ;

directDeclarator
    : Identifier
    | '(' declarator ')'
    | directDeclarator '[' constantExpression? ']'
    | directDeclarator '(' parameterTypeList ')'
    | directDeclarator '(' identifierList? ')'
    ;

pointer
    : '*' typeQualifierList? pointer?
    ;

typeQualifierList
    : typeQualifier+
    ;

parameterTypeList
    : parameterList (',' '...')?
    ;

parameterList
    : parameterDeclaration (',' parameterDeclaration)*
    ;

parameterDeclaration
    : declarationSpecifiers declarator
    | declarationSpecifiers abstractDeclarator?
    ;

identifierList
    : Identifier (',' Identifier)*
    ;

initializer
    : assignmentExpression
    | '{' initializerList ','? '}'
    ;

initializerList
    : initializer (',' initializer)*
    ;

typedefName
    : Identifier
    ;

abstractDeclarator
    : pointer
    | pointer? directAbstractDeclaratorSuffix
    ;

directAbstractDeclaratorSuffix
    : '(' abstractDeclarator ')' suffixPart*
    | suffixPart+
    ;

suffixPart
    : '[' constantExpression? ']'
    | '(' parameterTypeList? ')'
    ;

statement
    : labeledStatement
    | compoundStatement
    | expressionStatement
    | selectionStatement
    | iterationStatement
    | jumpStatement
    ;

labeledStatement
    : Identifier ':' statement
    | 'case' constantExpression ':' statement
    | 'default' ':' statement
    ;

compoundStatement
    : '{' blockItemList? '}'
    ;

blockItemList
    : blockItem+
    ;

blockItem
    : declaration
    | statement
    ;

expressionStatement
    : expression? ';'
    ;

selectionStatement
    : 'if' '(' expression ')' statement ('else' statement)?
    | 'switch' '(' expression ')' statement
    ;

iterationStatement
    : 'while' '(' expression ')' statement
    | 'do' statement 'while' '(' expression ')' ';'
    | 'for' '(' expression? ';' expression? ';' expression? ')' statement
    | 'for' '(' declaration expression? ';' expression? ')' statement
    ;

jumpStatement
    : 'goto' Identifier ';'
    | 'continue' ';'
    | 'break' ';'
    | 'return' expression? ';'
    ;

expression
    : assignmentExpression (',' assignmentExpression)*
    ;

assignmentExpression
    : conditionalExpression
    | unaryExpression assignmentOperator assignmentExpression
    ;

assignmentOperator
    : '=' | '*=' | '/=' | '%=' | '+=' | '-=' | '<<=' | '>>=' | '&=' | '^=' | '|='
    ;

conditionalExpression
    : logicalOrExpression ('?' expression ':' conditionalExpression)?
    ;

constantExpression
    : conditionalExpression
    ;

logicalOrExpression
    : logicalAndExpression ('||' logicalAndExpression)*
    ;

logicalAndExpression
    : inclusiveOrExpression ('&&' inclusiveOrExpression)*
    ;

inclusiveOrExpression
    : exclusiveOrExpression ('|' exclusiveOrExpression)*
    ;

exclusiveOrExpression
    : andExpression ('^' andExpression)*
    ;

andExpression
    : equalityExpression ('&' equalityExpression)*
    ;

equalityExpression
    : relationalExpression (('=='|'!=') relationalExpression)*
    ;

relationalExpression
    : shiftExpression (('<'|'>'|'<='|'>=') shiftExpression)*
    ;

shiftExpression
    : additiveExpression (('<<'|'>>') additiveExpression)*
    ;

additiveExpression
    : multiplicativeExpression (('+'|'-') multiplicativeExpression)*
    ;

multiplicativeExpression
    : castExpression (('*'|'/'|'%') castExpression)*
    ;

castExpression
    : unaryExpression
    | '(' typeName ')' castExpression
    ;

unaryExpression
    : postfixExpression
    | '++' unaryExpression
    | '--' unaryExpression
    | unaryOperator castExpression
    | 'sizeof' unaryExpression
    | 'sizeof' '(' typeName ')'
    ;

unaryOperator
    : '&' | '*' | '+' | '-' | '~' | '!'
    ;

postfixExpression
    : primaryExpression
    | postfixExpression '[' expression ']'
    | postfixExpression '(' argumentExpressionList? ')'
    | postfixExpression '.' Identifier
    | postfixExpression '->' Identifier
    | postfixExpression '++'
    | postfixExpression '--'
    ;

primaryExpression
    : Identifier
    | Constant
    | StringLiteral+
    | '(' expression ')'
    ;

argumentExpressionList
    : assignmentExpression (',' assignmentExpression)*
    ;

typeName
    : specifierQualifierList abstractDeclarator?
    ;

// Lexer Rules
Identifier
    : IdentifierNondigit (IdentifierNondigit | Digit)*
    ;

fragment IdentifierNondigit
    : [a-zA-Z_]
    ;

fragment Digit
    : [0-9]
    ;

Constant
    : IntegerConstant
    | FloatingConstant
    | CharacterConstant
    ;

fragment IntegerConstant
    : DecimalConstant IntegerSuffix?
    | OctalConstant IntegerSuffix?
    | HexadecimalConstant IntegerSuffix?
    ;

fragment DecimalConstant
    : NonzeroDigit Digit*
    ;

fragment OctalConstant
    : '0' OctalDigit*
    ;

fragment HexadecimalConstant
    : HexadecimalPrefix HexadecimalDigit+
    ;

fragment HexadecimalPrefix
    : '0' [xX]
    ;

fragment NonzeroDigit
    : [1-9]
    ;

fragment OctalDigit
    : [0-7]
    ;

fragment HexadecimalDigit
    : [0-9a-fA-F]
    ;

fragment IntegerSuffix
    : UnsignedSuffix LongSuffix?
    | UnsignedSuffix LongLongSuffix
    | LongSuffix UnsignedSuffix?
    | LongLongSuffix UnsignedSuffix?
    ;

fragment UnsignedSuffix
    : [uU]
    ;

fragment LongSuffix
    : [lL]
    ;

fragment LongLongSuffix
    : 'll' | 'LL'
    ;

fragment FloatingConstant
    : DecimalFloatingConstant
    | HexadecimalFloatingConstant
    ;

fragment DecimalFloatingConstant
    : FractionalConstant ExponentPart? FloatingSuffix?
    | DigitSequence ExponentPart FloatingSuffix?
    ;

fragment HexadecimalFloatingConstant
    : HexadecimalPrefix HexadecimalFractionalConstant BinaryExponentPart FloatingSuffix?
    | HexadecimalPrefix HexadecimalDigitSequence BinaryExponentPart FloatingSuffix?
    ;

fragment FractionalConstant
    : DigitSequence? '.' DigitSequence
    | DigitSequence '.'
    ;

fragment ExponentPart
    : [eE] Sign? DigitSequence
    ;

fragment Sign
    : [+-]
    ;

fragment DigitSequence
    : Digit+
    ;

fragment HexadecimalFractionalConstant
    : HexadecimalDigitSequence? '.' HexadecimalDigitSequence
    | HexadecimalDigitSequence '.'
    ;

fragment BinaryExponentPart
    : [pP] Sign? DigitSequence
    ;

fragment HexadecimalDigitSequence
    : HexadecimalDigit+
    ;

fragment FloatingSuffix
    : [flFL]
    ;

fragment CharacterConstant
    : '\'' CChar+ '\''
    | 'L\'' CChar+ '\''
    ;

fragment CChar
    : ~['\\\r\n]
    | EscapeSequence
    ;

fragment EscapeSequence
    : SimpleEscapeSequence
    | OctalEscapeSequence
    | HexadecimalEscapeSequence
    ;

fragment SimpleEscapeSequence
    : '\\' ['"?abfnrtv\\]
    ;

fragment OctalEscapeSequence
    : '\\' OctalDigit OctalDigit? OctalDigit?
    ;

fragment HexadecimalEscapeSequence
    : '\\x' HexadecimalDigit+
    ;

StringLiteral
    : '"' SChar* '"'
    | 'L"' SChar* '"'
    ;

fragment SChar
    : ~["\\\r\n]
    | EscapeSequence
    ;

// Whitespace and comments
Whitespace
    : [ \t\r\n]+ -> skip
    ;

BlockComment
    : '/*' .*? '*/' -> skip
    ;

LineComment
    : '//' ~[\r\n]* -> skip
    ;

Preprocessor
    : '#' ~[\r\n]* -> skip
    ;
