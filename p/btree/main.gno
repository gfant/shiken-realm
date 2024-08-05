package btree

import (
	ufmt "gno.land/p/demo/ufmt"
)

type UserRecord struct {
	gasUsed int
	address string
}

type BTreeNode struct {
	keys     []int        // keys in node
	children []*BTreeNode // pointers to children
	leaf     bool         // Node is leaf or not
	n        int          // amount of stored vals in node
}

type BTree struct {
	root *BTreeNode
	t    int // min grade
}

/*
func main() {
	tree := NewBTree(3)

	tree.Insert(3)
	tree.Insert(15)
	tree.Insert(10)
	tree.Insert(11)
   	tree.Insert(40)

	   tree.InOrderTraversal()
	   ufmt.Println(tree.GetSmallest())
	   ufmt.Println(tree.GetGreatest())
}
*/

// Create new B-tree
func NewBTree(t int) *BTree {
	return &BTree{
		root: &BTreeNode{
			keys:     make([]int, 0),        // Create empty array since it's just a new node
			children: make([]*BTreeNode, 0), // Create empty array since no node has been added yet
			leaf:     true,
		},
		t: t,
	}
}

// Search in B-tree
func (bt *BTree) Search(k int) *BTreeNode {
	return search(bt.root, k)
}

func search(bt *BTreeNode, k int) *BTreeNode {
	i := 0
	for i < bt.n && k > bt.keys[i] {
		i++
	}
	if i < bt.n && k == bt.keys[i] {
		return bt
	} else if bt.leaf {
		return nil
	} else {
		return search(bt.children[i], k)
	}
}

func (bt *BTree) splitChild(x *BTreeNode, i int) {
	t := bt.t
	y := x.children[i]
	z := &BTreeNode{
		keys:     make([]int, t-1),
		children: make([]*BTreeNode, 0),
		leaf:     y.leaf,
		n:        t - 1,
	}

	// Copies the last (t-1) keys from y to z
	copy(z.keys, y.keys[t:])
	if !y.leaf {
		z.children = make([]*BTreeNode, t)
		copy(z.children, y.children[t:])
	}

	y.keys = y.keys[:t-1]
	y.n = t - 1

	x.children = append(x.children[:i+1], append([]*BTreeNode{z}, x.children[i+1:]...)...)
	x.keys = append(x.keys[:i], append([]int{y.keys[t-1]}, x.keys[i:]...)...)
	x.n++
}

// Insert new val
func (bt *BTree) Insert(k int) {
	root := bt.root
	if root.n == 2*bt.t-1 {
		s := &BTreeNode{
			keys:     make([]int, 0),
			children: make([]*BTreeNode, 0),
			leaf:     false,
		}
		bt.root = s
		s.children = append(s.children, root)
		bt.splitChild(s, 0)
		bt.insertNonFull(s, k)
	} else {
		bt.insertNonFull(root, k)
	}
}

// Insert if the node isn't full
func (bt *BTree) insertNonFull(x *BTreeNode, k int) {
	i := x.n - 1
	if x.leaf {
		x.keys = append(x.keys, 0)
		for i >= 0 && k < x.keys[i] {
			x.keys[i+1] = x.keys[i]
			i--
		}
		x.keys[i+1] = k
		x.n++
	} else {
		for i >= 0 && k < x.keys[i] {
			i--
		}
		i++
		if x.children[i].n == 2*bt.t-1 {
			bt.splitChild(x, i)
			if k > x.keys[i] {
				i++
			}
		}
		bt.insertNonFull(x.children[i], k)
	}
}

// Delete key
func (bt *BTree) Delete(k int) {
	if bt.root == nil {
		return
	}
	bt.delete(bt.root, k)
	if bt.root.n == 0 {
		if bt.root.leaf {
			bt.root = nil
		} else {
			bt.root = bt.root.children[0]
		}
	}
}

func (bt *BTree) delete(x *BTreeNode, k int) {
	t := bt.t
	i := 0
	for i < x.n && k > x.keys[i] {
		i++
	}

	if i < x.n && k == x.keys[i] {
		// La clave está en el nodo x
		if x.leaf {
			// Caso 1: La clave está en un nodo hoja
			x.keys = append(x.keys[:i], x.keys[i+1:]...)
			x.n--
		} else {
			// Caso 2: La clave está en un nodo interno
			if len(x.children[i].keys) >= t {
				// Caso 2a: Predecesor tiene al menos t claves
				pred := x.children[i]
				for !pred.leaf {
					pred = pred.children[pred.n]
				}
				predKey := pred.keys[pred.n-1]
				x.keys[i] = predKey
				bt.delete(x.children[i], predKey)
			} else if len(x.children[i+1].keys) >= t {
				// Caso 2b: Sucesor tiene al menos t claves
				succ := x.children[i+1]
				for !succ.leaf {
					succ = succ.children[0]
				}
				succKey := succ.keys[0]
				x.keys[i] = succKey
				bt.delete(x.children[i+1], succKey)
			} else {
				// Caso 2c: Ambos hijos tienen menos de t claves
				bt.merge(x, i)
				bt.delete(x.children[i], k)
			}
		}
	} else if !x.leaf {
		// La clave no está en el nodo y es un nodo interno
		if len(x.children[i].keys) < t {
			bt.fill(x, i)
		}
		if i > x.n {
			bt.delete(x.children[i-1], k)
		} else {
			bt.delete(x.children[i], k)
		}
	}
}

// Rellena el hijo x.children[i] si tiene menos de t claves
func (bt *BTree) fill(x *BTreeNode, i int) {
	t := bt.t
	if i != 0 && len(x.children[i-1].keys) >= t {
		bt.borrowFromPrev(x, i)
	} else if i != x.n && len(x.children[i+1].keys) >= t {
		bt.borrowFromNext(x, i)
	} else {
		if i != x.n {
			bt.merge(x, i)
		} else {
			bt.merge(x, i-1)
		}
	}
}

// Toma prestado una clave del nodo x.children[i-1] y la inserta en x.children[i]
func (bt *BTree) borrowFromPrev(x *BTreeNode, i int) {
	child := x.children[i]
	sibling := x.children[i-1]

	// El último hijo de x.children[i-1] sube a x y el último de x baja a x.children[i]
	for j := child.n - 1; j >= 0; j-- {
		child.keys[j+1] = child.keys[j]
	}
	if !child.leaf {
		for j := child.n; j >= 0; j-- {
			child.children[j+1] = child.children[j]
		}
	}
	child.keys[0] = x.keys[i-1]
	if !x.leaf {
		child.children[0] = sibling.children[sibling.n]
	}
	x.keys[i-1] = sibling.keys[sibling.n-1]
	child.n++
	sibling.n--
}

// Toma prestado una clave del nodo x.children[i+1] y la inserta en x.children[i]
func (bt *BTree) borrowFromNext(x *BTreeNode, i int) {
	child := x.children[i]
	sibling := x.children[i+1]

	child.keys[child.n] = x.keys[i]
	if !child.leaf {
		child.children[child.n+1] = sibling.children[0]
	}
	x.keys[i] = sibling.keys[0]
	for j := 1; j < sibling.n; j++ {
		sibling.keys[j-1] = sibling.keys[j]
	}
	if !sibling.leaf {
		for j := 1; j <= sibling.n; j++ {
			sibling.children[j-1] = sibling.children[j]
		}
	}
	child.n++
	sibling.n--
}

// Fusiona x.children[i] y x.children[i+1]
func (bt *BTree) merge(x *BTreeNode, i int) {
	child := x.children[i]
	sibling := x.children[i+1]

	child.keys[bt.t-1] = x.keys[i]

	for j := 0; j < sibling.n; j++ {
		child.keys[j+bt.t] = sibling.keys[j]
	}
	if !child.leaf {
		for j := 0; j <= sibling.n; j++ {
			child.children[j+bt.t] = sibling.children[j]
		}
	}

	for j := i + 1; j < x.n; j++ {
		x.keys[j-1] = x.keys[j]
	}
	for j := i + 2; j <= x.n; j++ {
		x.children[j-1] = x.children[j]
	}
	child.n += sibling.n + 1
	x.n--
}

func (bt *BTree) InOrderTraversal() {
	if bt.root != nil {
		inOrderTraversal(bt.root)
	}
}

func inOrderTraversal(node *BTreeNode) {
	i := 0
	// Recorrer cada hijo y su subárbol izquierdo
	for i < node.n {
		if !node.leaf {
			inOrderTraversal(node.children[i])
		}
		// Imprimir la clave del nodo actual
		val := ufmt.Sprintf("%d ", node.keys[i])
		ufmt.Println(val)
		i++
	}

	// Recorrer el subárbol derecho del último hijo
	if !node.leaf {
		inOrderTraversal(node.children[i])
	}
}

func (bt *BTree) GetSmallest() int {
	if bt.root != nil {
		return getSmallest(bt.root)
	} else {
		return 0
	}
}

func getSmallest(node *BTreeNode) int {
	i := 0
	var val int
	if !node.leaf {
		val = getSmallest(node.children[i])
	} else {
		if node.n > 0 {
			val = node.keys[i]
		} else {
			val = -1
		}
	}
	return val
}

func (bt *BTree) GetGreatest() int {
	if bt.root != nil {
		return getGreatest(bt.root)
	} else {
		return 0
	}
}

func getGreatest(node *BTreeNode) int {
	i := node.n - 1
	var val int
	if !node.leaf {
		val = getGreatest(node.children[i])
	} else {
		if node.n > 0 {
			val = node.keys[i]
		} else {
			val = -1
		}
	}
	return val
}
