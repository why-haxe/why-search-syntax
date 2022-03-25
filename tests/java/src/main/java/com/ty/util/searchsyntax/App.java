package com.ty.util.searchsyntax;

import java.util.List;
import com.ty.util.searchsyntax.Parser;
import com.ty.util.searchsyntax.Term;
import com.ty.util.searchsyntax.internal.Expr;

/**
 * Dummy app to import the packaged JAR
 */
public class App 
{
    public static void main( String[] args )
    {
        List<Term> terms = Parser.parse("?field:>200|<300");
        
        
        System.out.println( terms.size() );
        System.out.println( terms.get(0).modifiers );
        System.out.println( terms.get(0).field );
        Expr expr = terms.get(0).expr;
        System.out.println( expr.getClass().toString() );
        
        final Visitor<String> visitor = new StringVisitor();
        final String result = visitor.visitExpr(expr);
        System.out.println(result);
    }
    
    static interface Visitor<Result> {
        default Result visitExpr(Expr expr) {
            if(expr instanceof Expr.Literal) {
                return visitLiteral((Expr.Literal) expr);
            } else if(expr instanceof Expr.Binop) {
                return visitBinop((Expr.Binop) expr);
            } else if(expr instanceof Expr.Unop) {
                return visitUnop((Expr.Unop) expr);
            } else {
                return null; // unreachable
            }
        }
        Result visitLiteral(Expr.Literal expr);
        Result visitBinop(Expr.Binop expr);
        Result visitUnop(Expr.Unop expr);
    }
        
        
    static class StringVisitor implements Visitor<String> {
        public void Visitor() {}
        
        public String visitLiteral(Expr.Literal expr) {
            return expr.value.toString();
        }
        
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
    }
    
}

