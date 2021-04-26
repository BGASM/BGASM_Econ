"""MIT License
Copyright (c) 2012 Nicolas Kruchten, Datacratic, other contributors
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."""

TEMPLATE = u"""
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>PivotTable.js</title>
        <!-- external libs from cdnjs -->
        <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.11/c3.min.css">
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script>
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.11/c3.min.js"></script>
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min.js"></script>
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery-csv/0.71/jquery.csv-0.71.min.js"></script>
        <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/pivottable/2.19.0/pivot.min.css">
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pivottable/2.19.0/pivot.min.js"></script>
        
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pivottable/2.19.0/export_renderers.min.js"></script>
        
        
        
        
        <style>
            body {font-family: Verdana;}
            .node {
              border: solid 1px white;
              font: 10px sans-serif;
              line-height: 12px;
              overflow: hidden;
              position: absolute;
              text-indent: 2px;
            }
            .c3-line, .c3-focused {stroke-width: 3px !important;}
            .c3-bar {stroke: white !important; stroke-width: 1;}
            .c3 text { font-size: 12px; color: grey;}
            .tick line {stroke: white;}
            .c3-axis path {stroke: grey;}
            .c3-circle { opacity: 1 !important; }
            .c3-xgrid-focus {visibility: hidden !important;}
            thead > tr > th.pvtTotalLabel, .rowTotal, .pvtGrandTotal { display: none; }
        </style>
    </head>
    <body>
        <script type="text/javascript">
            $(function(){
                if(window.location != window.parent.location)
                    $("<a>", {target:"_blank", href:""})
                        .text("[pop out]").prependTo($("body"));
                $("#output").pivotUI(
                    $.csv.toArrays($("#output").text()),
                    $.extend({
                        renderers: $.extend(
                            $.pivotUtilities.renderers,                            
                            $.pivotUtilities.export_renderers
                            ),
                        hiddenFromDragDrop: ["supply/demand", "profit/cost", "price"]
                    }, %(kwargs)s)
                ).show();
             });
        </script>        
        <div id="output" style="display: none;">%(csv)s</div>        
    </body>
</html>
"""

import json, io
from csv import DictWriter


def pivot_ui(df, outfile_path="pivottablejs.html", url="", width="100%", height="500", **kwargs):
    output = io.StringIO()
    keys = df[0].keys()

    writer = DictWriter(output, fieldnames=keys)
    writer.writeheader()
    for x in df:
        writer.writerow(x)

    with io.open(outfile_path, 'wt', encoding='utf8') as outfile:
        # csv = df.to_csv(encoding='utf8')
        csv = output.getvalue().replace("\r\n", "\n")
        if hasattr(csv, 'decode'):
            csv = csv.decode('utf8')
        outfile.write(TEMPLATE %
                      dict(csv=csv, kwargs=json.dumps(kwargs)))
