export declare class Parser {
  static parse(text: string): Term[];
}

export declare interface Term {
  modifiers: Modifier[];
  field: string;
  expr: Expr;
}

// prettier-ignore
export declare namespace Expr {
  export type Binop = { _hx_index: 0; $kind: 'Binop'; op: BinOp; expr1: Expr; expr2: Expr };
  export type Unop = { _hx_index: 1; $kind: 'Unop'; op: UnOp; expr: Expr };
  export type Literal = { _hx_index: 2; $kind: 'Literal'; value: LiteralValue };

  export const Binop: (op: string, expr1: Expr, expr2: Expr) => Expr;
  export const Unop: (op: UnOp, expr: Expr) => Expr;
  export const Literal: (value: LiteralValue) => Expr;
}

export declare type Expr = Expr.Unop | Expr.Literal | Expr.Binop;

// prettier-ignore
export declare namespace Literal {
  export type QuotedText = { _hx_index: 0; $kind: 'QuotedText'; quote: Quote; value: string };
  export type Text = { _hx_index: 1; $kind: 'Text'; value: string };
  export type Regex = { _hx_index: 2; $kind: 'Regex'; pattern: string };
  export type Template = { _hx_index: 3; $kind: 'Template'; parts: TemplatePart[] };

  export const QuotedText: (quote: string, value: string) => Literal;
  export const Text: (value: string) => Literal;
  export const Regex: (pattern: string) => Literal;
  export const Template: (parts: TemplatePart[]) => Literal;
}

export declare type Literal =
  | Literal.Text
  | Literal.Regex
  | Literal.QuotedText
  | Literal.Template;
type LiteralValue = Literal;

export declare namespace TemplatePart {
  export type Text = { _hx_index: 0; $kind: 'Text'; value: string };
  export type Syntax = { _hx_index: 1; $kind: 'Syntax'; terms: Term[] };

  export const Text: (value: string) => TemplatePart;
  export const Syntax: (terms: Term[]) => TemplatePart;
}
export declare type TemplatePart = TemplatePart.Text | TemplatePart.Syntax;

type Modifier = '!' | '?';
type UnOp = '!' | '>' | '>=' | '<' | '<=';
type BinOp = ',' | '|' | '..';
type Quote = '"';
