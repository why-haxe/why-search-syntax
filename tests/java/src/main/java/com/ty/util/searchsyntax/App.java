package com.ty.util.searchsyntax;

import java.util.List;
import com.ty.util.searchsyntax.Parser;
import com.ty.util.searchsyntax.Term;
import com.ty.util.searchsyntax.internal.Expr;
import com.ty.util.searchsyntax.internal.Literal;

/**
 * Dummy app to import the packaged JAR
 */
public class App 
{
    public static void main( String[] args )
    {
        List<Term> terms = Parser.parse("?field:>200|<300 quoted:\"foo\\\"bar\"");
        
        System.out.println( terms.size() );
        System.out.println( terms.get(0).modifiers );
        System.out.println( terms.get(0).field );
        
        for(Term term : terms) {
            Expr expr = term.expr;
            System.out.println( expr.getClass().toString() );
            
            final Visitor<String> visitor = new StringVisitor();
            final String result = visitor.visitExpr(expr);
            System.out.println(result);
        }
    }
    
    static interface Visitor<Result> {
        default Result visitExpr(Expr expr) {
            if(expr instanceof Expr.Literal) {
                return visitLiteral(((Expr.Literal) expr).value);
            } else if(expr instanceof Expr.Binop) {
                return visitBinop((Expr.Binop) expr);
            } else if(expr instanceof Expr.Unop) {
                return visitUnop((Expr.Unop) expr);
            } else {
                return null; // unreachable
            }
        }
        default Result visitLiteral(Literal literal) {
            if(literal instanceof Literal.QuotedText) {
                return visitQuotedText((Literal.QuotedText) literal);
            } else if(literal instanceof Literal.Text) {
                return visitText((Literal.Text) literal);
            } else if(literal instanceof Literal.Regex) {
                return visitRegex((Literal.Regex) literal);
            } else {
                return null; // unreachable
            }
        }
        Result visitBinop(Expr.Binop expr);
        Result visitUnop(Expr.Unop expr);
        
        Result visitQuotedText(Literal.QuotedText literal);
        Result visitText(Literal.Text literal);
        Result visitRegex(Literal.Regex literal);
    }
        
        
    static class StringVisitor implements Visitor<String> {
        public void Visitor() {}
        
        public String visitBinop(Expr.Binop expr) {
            return 
                visitExpr(expr.expr1) + 
                expr.op +
                visitExpr(expr.expr2);
        }
        
        public String visitUnop(Expr.Unop expr) {
            return 
                expr.op +
                visitExpr(expr.expr);
        }
        
        public String visitLiteral(Expr.Literal expr) {
            return expr.value.toString();
        }
        
        public String visitQuotedText(Literal.QuotedText literal) {
            return literal.value + " [quoted with " + literal.quote + "]";
        }
        public String visitText(Literal.Text literal) {
            return literal.value;
        }
        public String visitRegex(Literal.Regex literal) {
            return "/" + literal.pattern + "/";
        }
    }
    
}

