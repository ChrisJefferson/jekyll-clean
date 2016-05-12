---
---


const graphlist = [
"Example-d1.json",
"Example-d2.json",
"Frucht.json",
"4cube.bliss.json",
"grid-w-3-4.json",
"paley-9.json",
"graph.json",
"house.json",
"pp-2-1.json",
"grid-3-3.json",
"paley-17.json",
"tran_12_24.bliss.json"
];


function loadGraph(divname, graphname) {
  var storeGraph = null;

  var width = 500,
  height = 300;

  var highlighted = null;

  var currentgraph = graphname;


  var svg = d3.select(divname).append("svg")
  .attr("width", width)
  .attr("height", height)
  .attr("style", "outline: thin solid grey");


  var updateVertices = function() {
    svg.selectAll(".node").data(storeGraph.nodes)
    .style("fill", function(d) { return colourlist[d.group]; })
    .style("stroke", function(o) {
      return (o===highlighted) ? "red" : "blue";
    });
  }
  
  function filterUpdate() {
    var g, p, p2;
    g = JSONToGraph(storeGraph);
    p = JSONToPartition(storeGraph);
    p2 = filterDirectedGraph(p, g);
    PartitionToJSON(storeGraph, p2);
    updateVertices();
  }


  function readGraph(gname) {
    d3.json(gname, function(error, graph) {
      if(error) throw error;
      storeGraph = graph;
      force.nodes(graph.nodes).links(graph.links);
      updateVertices();
    });
  }
  

  var menu = d3.select(divname).append("select");
  
  menu.selectAll("option")
                  .data(graphlist)
                  .enter()
                  .append("option")
                  .text(function(d) { return d; })
                  .attr("value", function(d) { return d; });
  
  menu.on("change", x => initaliseGraph("/assets/graphs/"+d3.event.target.value));
  
  var resetButton = d3.select(divname).append("button")
                 .attr("type", "button")
                 .attr("text", "filter")
                 .text("reset")
                 .on("click", x => initaliseGraph(currentgraph));

  var filterButton = d3.select(divname).append("button")
                 .attr("type", "button")
                 .attr("text", "filter")
                 .text("filter")
                 .on("click", filterUpdate);


  function initaliseGraph(gname) {
    currentgraph = gname;
    console.log(gname);
    d3.json(gname, function(error, graph) {
      if (error) throw error;
      
      let len = _.size(graph.nodes);
      let dist = _.min([width, height])/2;
      
      // Let's set some non-mad initial vertex locations
      for(let i of _.range(len)) {
        if(graph.nodes[i].x === undefined) {
          graph.nodes[i].x = Math.sin(Math.PI * 2 * len / i);
        }
        graph.nodes[i].x = graph.nodes[i].x * dist + width/2;
        graph.nodes[i].px = graph.nodes[i].x;
        if(graph.nodes[i].y === undefined) {
          graph.nodes[i].y = Math.cos(Math.PI * 2 * len / i);
        }
        graph.nodes[i].y = graph.nodes[i].y * dist + height/2;
        graph.nodes[i].py = graph.nodes[i].y;
      }
      
      storeGraph = graph;
      
      svg.selectAll("*").remove();
      
      var force = d3.layout.force()
      .linkDistance(80)
      .charge(-320)
      .gravity(0.1)
      //.linkStrength(0.1)
      .size([width, height]);
      
      force
      .nodes(graph.nodes)
      .links(graph.links)
      .start();

// define arrow markers for graph links
svg.append('svg:defs').append('svg:marker')
    .attr('id', 'end-arrow')
    .attr('viewBox', '0 -5 10 10')
    .attr('refX', 6)
    .attr('markerWidth', 5)
    .attr('markerHeight', 5)
    .attr('orient', 'auto')
  .append('svg:path')
    .attr('d', 'M0,-5L10,0L0,5')
    .attr('fill', '#000');

svg.append('svg:defs').append('svg:marker')
    .attr('id', 'start-arrow')
    .attr('viewBox', '0 -5 10 10')
    .attr('refX', 4)
    .attr('markerWidth', 5)
    .attr('markerHeight', 5)
    .attr('orient', 'auto')
  .append('svg:path')
    .attr('d', 'M10,-5L0,0L10,5')
    .attr('fill', '#000');

      var link = svg.selectAll(".link")
      .data(graph.links)
      .enter().append("svg:polyline")
      .attr("class", "link")
      .style("stroke-width", function(d) { return Math.sqrt(d.value); })
      .style('marker-mid', function(d) { if(d.dir == 1) return 'url(#start-arrow)';
                                         else if(d.dir == -1) return 'url(#end-arrow)';
                                         else return ''; })

      var node = svg.selectAll(".node")
      .data(graph.nodes)
      .enter().append("circle")
      .attr("class", "node")
      .attr("r", 12)
      .call(force.drag);

      node.on("mouseover",
      function(d) { highlighted = d; updateVertices(); });

      node.on("mouseout",
      function(d) { highlighted = null; updateVertices(); });

      updateVertices();

      d3.select("body")
      .on("keydown", function() {
        var code = d3.event.keyCode;
        if(code < 48 || code > 57) return;
        if(highlighted === null) return;
        code = code - 48;
        storeGraph.nodes[highlighted.index].group = code;
        updateVertices();
      });

      force.on("tick", function() {
        link.attr("points", function(d) {
          return d.source.x + "," + d.source.y + " " +
                (d.source.x + d.target.x)/2 + "," + (d.source.y + d.target.y)/2 + " " +
                 d.target.x + "," + d.target.y; });

        node.attr("cx", function(d) { return Math.max(12, Math.min(width-12, d.x)); })
        .attr("cy", function(d) { return Math.max(12, Math.min(height-12, d.y)); });
      });
  });
};

initaliseGraph(graphname);

}
