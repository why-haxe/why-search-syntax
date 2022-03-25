package tests.java.src.main.java.com.ty.util.searchsyntax;

import java.util.List;
import com.ty.util.searchsyntax.Parser;
import com.ty.util.searchsyntax.Term;
import com.ty.util.searchsyntax.internal.Expr;
// import com.ty.util.searchsyntax.internal.Expr.Literal;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
        List<Term> terms = Parser.parse("?field:>name");
        
        
        System.out.println( terms.size() );
        System.out.println( terms.get(0).modifiers );
        System.out.println( terms.get(0).field );
        Expr expr = terms.get(0).expr;
        System.out.println( expr.getClass().toString() );
        
        
        if(expr instanceof Expr.Literal) {
            System.out.println( "is literal" );
        } else if(expr instanceof Expr.Binop) {
            System.out.println( "is binop" );
        } else if(expr instanceof Expr.Unop) {
            Expr.Unop unop = (Expr.Unop) expr;
            System.out.println( unop.expr );
            System.out.println( "is unop" );
        } else {
            System.out.println( "unreachable" );
        }
        
    }
    
    static class Visitor {
        public Visitor() {}
        
        public visitExpr(Expr expr) {
            if(expr instanceof Expr.Literal) {
                visitIteral((Expr.Literal) expr);
            } else if(expr instanceof Expr.Binop) {
                visitBinop((Expr.Binop) expr);
            } else if(expr instanceof Expr.Unop) {
                visitUnop((Expr.Unop) expr);
            }
        }
        public visitIteral(Expr.Literal expr) {
            
        }
        public visitBinop(Expr.Binop expr) {
            
        }
        public visitUnop(Expr.Unop expr) {
            
        }
    }
    
}

