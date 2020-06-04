public class FC_FusionObject {
    public String name { get; private set; }
    public String namespace { get; private set; }
    
    private Pair[] elements = new List<Pair>();
    
    class Pair {
        String name;
        String namespace;
        Object value;
        Pair(String name, String namespace, Object value) {
            this.name = name;
            this.namespace = namespace;
            this.value = value;
        }
    }
    
    public FC_FusionObject(String name, String namespace) {
        this.name = name;
        this.namespace = namespace;
    }
    public void setValue(String field, String namespace, Object obj) {
        elements.add(new Pair(field, namespace, obj));
    }
    public void setGroup(FC_FusionObject fo) {
        setValue(fo.name, fo.namespace, fo);
    }
    
    public Object getValue(String field) {
        for (Pair p : elements) {
            if (p.name == field) {
                return p.value;
            }
        }
        throw new FC_Exception('Value not found: ' + field);
        return null;
    }
    
    // public Object[] getAllValues(String field) {
    //     Object[] objects = new List<Object>();
    //     for (Pair p : elements) {
    //         if (p.name == field) {
    //             objects.add(p.value);
    //         }
    //     }
    //     if (objects.size() == 0) {
    //         throw new FC_FusionException('Value not found: ' + field);
    //     }
    //     return objects;
    // }
    
    public void addAsChildTo(Dom.xmlNode rootNode) {
        
        Dom.xmlNode containerNode = rootNode.addChildElement(name, namespace, null);
        for (Pair p : elements) {
            Object obj = p.value;
            if (obj != null) {
                if (obj instanceOf FC_FusionObject) {
                    FC_FusionObject fo = (FC_FusionObject) obj;
                    fo.addAsChildTo(containerNode);
                } else {
                    containerNode.addChildElement(p.name, p.namespace, null).addTextNode(String.valueOf(obj));
                }
            }
        }
    }
}