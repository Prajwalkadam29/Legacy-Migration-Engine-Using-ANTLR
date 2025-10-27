"""
backend/parser.py
Parse C source into a JSON-serializable AST using ANTLR4.
"""
import sys
from pathlib import Path
import ujson as json
from antlr4 import *
from antlr4.tree.Trees import Trees

# Add grammar directory to path
GRAMMAR_DIR = Path(__file__).resolve().parents[1] / 'grammar'
if str(GRAMMAR_DIR) not in sys.path:
    sys.path.insert(0, str(GRAMMAR_DIR))

from CLexer import CLexer
from CParser import CParser
from CVisitor import CVisitor


class ASTBuilderVisitor(CVisitor):
    """
    Custom visitor that converts ANTLR parse tree into a JSON-serializable AST dict.
    """
    
    def __init__(self, parser):
        self.parser = parser
        self.node_counter = 0
    
    def get_node_id(self):
        """Generate unique node IDs"""
        self.node_counter += 1
        return f"node_{self.node_counter}"
    
    def visitChildren(self, node):
        """Override to collect all children into a list"""
        if not node:
            return None
        
        # Get rule name
        if hasattr(node, 'getRuleIndex'):
            rule_idx = node.getRuleIndex()
            rule_name = self.parser.ruleNames[rule_idx] if rule_idx >= 0 else 'Unknown'
        else:
            rule_name = 'Terminal'
        
        # Build node dict
        result = {
            'id': self.get_node_id(),
            'kind': rule_name,
            'spelling': '',
            'type': '',
            'children': []
        }
        
        # Get text content
        if hasattr(node, 'getText'):
            text = node.getText()
            if len(text) < 100:  # Avoid huge text blocks
                result['spelling'] = text
        
        # Get location info
        if hasattr(node, 'start'):
            result['line'] = node.start.line
            result['column'] = node.start.column
        
        # Process children
        if hasattr(node, 'getChildCount'):
            for i in range(node.getChildCount()):
                child = node.getChild(i)
                child_node = self.visit(child)
                if child_node:
                    result['children'].append(child_node)
        
        return result
    
    def visitTerminal(self, node):
        """Handle terminal nodes (tokens)"""
        return {
            'id': self.get_node_id(),
            'kind': 'Terminal',
            'spelling': node.getText(),
            'type': self.parser.symbolicNames[node.symbol.type] if node.symbol.type < len(self.parser.symbolicNames) else 'Unknown',
            'line': node.symbol.line,
            'column': node.symbol.column,
            'children': []
        }
    
    def visitErrorNode(self, node):
        """Handle error nodes"""
        return {
            'id': self.get_node_id(),
            'kind': 'ErrorNode',
            'spelling': node.getText(),
            'type': 'error',
            'children': []
        }


def parse_c_file_to_ast_dict(path: str) -> dict:
    """
    Parse C source file at `path` into a nested dict AST using ANTLR4.
    """
    path = Path(path)
    if not path.exists():
        raise FileNotFoundError(f"File not found: {path}")
    
    try:
        # Read file content
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            code = f.read()
        
        return parse_c_code_str_to_ast(code, filename=str(path))
    
    except Exception as e:
        print(f"Error parsing file {path}: {e}")
        raise


def parse_c_code_str_to_ast(code: str, filename: str = 'temp.c') -> dict:
    """
    Use ANTLR4 to parse a string of C code.
    """
    try:
        # Create input stream
        input_stream = InputStream(code)
        
        # Create lexer
        lexer = CLexer(input_stream)
        
        # Create token stream
        token_stream = CommonTokenStream(lexer)
        
        # Create parser
        parser = CParser(token_stream)
        
        # Optional: Remove default error listeners
        parser.removeErrorListeners()
        
        # Add custom error listener if needed
        # parser.addErrorListener(CustomErrorListener())
        
        # Parse the compilation unit (root rule)
        tree = parser.compilationUnit()
        
        # Build AST using visitor
        visitor = ASTBuilderVisitor(parser)
        ast_dict = visitor.visit(tree)
        
        # Add metadata
        ast_dict['filename'] = filename
        ast_dict['source'] = 'ANTLR4'
        
        return ast_dict
    
    except Exception as e:
        print(f"Error parsing C code: {e}")
        # Return minimal error node
        return {
            'id': 'error_root',
            'kind': 'ParseError',
            'spelling': f'Error: {str(e)}',
            'type': 'error',
            'filename': filename,
            'children': []
        }


def simplify_ast(node: dict, max_depth: int = 10, current_depth: int = 0) -> dict:
    """
    Simplify AST by removing empty nodes and limiting depth.
    Useful for reducing AST size before storing in Neo4j.
    """
    if current_depth >= max_depth:
        return {
            'id': node.get('id', 'unknown'),
            'kind': node.get('kind', 'Unknown'),
            'spelling': node.get('spelling', ''),
            'type': node.get('type', ''),
            'children': []
        }
    
    # Filter out children that are just whitespace or empty
    children = node.get('children', [])
    filtered_children = []
    
    for child in children:
        spelling = child.get('spelling', '').strip()
        # Skip pure whitespace nodes
        if not spelling or len(spelling) > 0:
            simplified_child = simplify_ast(child, max_depth, current_depth + 1)
            filtered_children.append(simplified_child)
    
    return {
        'id': node.get('id', 'unknown'),
        'kind': node.get('kind', 'Unknown'),
        'spelling': node.get('spelling', ''),
        'type': node.get('type', ''),
        'line': node.get('line', 0),
        'column': node.get('column', 0),
        'children': filtered_children
    }


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python backend/parser.py path/to/file.c")
        sys.exit(1)
    
    try:
        ast = parse_c_file_to_ast_dict(sys.argv[1])
        print(json.dumps(ast, indent=2))
    except Exception as e:
        print(f"Failed to parse: {e}")
        sys.exit(1)
