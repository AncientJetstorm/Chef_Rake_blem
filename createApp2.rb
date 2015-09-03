require 'fileutils'
require 'yaml'

data = YAML.load_file('config.yaml')
app_name = data['Chart1']['AppName']
tablecount = 0

FileUtils::mkdir_p app_name + '/appserver'
FileUtils::mkdir_p app_name + '/appserver/templates'
f = File.open(app_name + '/appserver/templates/redirect.tmpl', 'w')
f.write("<%
import cherrypy, re
from lib.i18n import current_lang
root_endpoint = cherrypy.request.config.get('root_endpoint')
root = (root_endpoint or '') + '/'
# Remove duplicate slashes at beginning/end of root_endpoint
root = re.sub(r'(/)\\1+$', r'\\1', re.sub(r'^(/)\\1+', r'\\1', root))
locale = \"-\".join([ x.lower() for x in current_lang()[0:2] if x is not None ])
%>
<!DOCTYPE html>
<script type=\"text/javascript\">
    document.location = \"${root}dj/${locale}/${APP['id']}\"
</script>")
f.close

FileUtils::mkdir_p app_name + '/bin'
f = File.open(app_name + '/bin/README', 'w')
f.write("Put search commands, scripted inputs and scripted lookups here...
")
f.close

FileUtils::mkdir_p app_name + '/default'
f = File.open(app_name + '/default/app.conf', 'w')
f.write("#
# Splunk app configuration file
#

[install]
is_configured = 0

[package]
id = " + app_name + "

[ui]
is_visible = True
label = " + app_name + "

[launcher]
author = 
description = 
version = 1.0
")
f.close

FileUtils::mkdir_p app_name + '/default/data'
FileUtils::mkdir_p app_name + '/default/data/ui'
FileUtils::mkdir_p app_name + '/default/data/ui/nav'
f = File.open(app_name + '/default/data/ui/nav/default.xml', 'w')
f.write("<nav>
    <view name=\"default\" default=\"true\"/>
    <a href=\"/dj/redirector/" + app_name + "/home\">Home</a>
</nav>")
f.close

FileUtils::mkdir_p app_name + '/default/data/ui/views'
f = File.open(app_name + '/default/data/ui/views/default.xml', 'w')
f.write("<view template=\"" + app_name + ":/templates/redirect.tmpl\" isVisible=\"false\"><label>Home</label></view>")
f.close

FileUtils::mkdir_p app_name + '/django'
FileUtils::mkdir_p app_name + '/django/' + app_name
f = File.open(app_name + '/django/' + app_name + '/__init__.py', 'w')
f.write("# Copyright 2015")
f.close

f = File.open(app_name + '/django/' + app_name + '/tests.py', 'w')
f.write("\"\"\"
This file demonstrates writing tests using the unittest module. These will pass
when you run \"manage.py test\".

Replace this with more appropriate tests for your application.
\"\"\"

from django.test import TestCase


class SimpleTest(TestCase):
    def test_basic_addition(self):
        \"\"\"
        Tests that 1 + 1 always equals 2.
        \"\"\"
        self.assertEqual(1 + 1, 2)
        ")
f.close

f = File.open(app_name + '/django/' + app_name + '/urls.py', 'w')
f.write("from django.conf.urls import patterns, include, url
from splunkdj.utility.views import render_template as render

urlpatterns = patterns('',
    url(r'^home/$', '" + app_name + ".views.home', name='home'), 
)
")
f.close

f = File.open(app_name + '/django/' + app_name + '/views.py', 'w')
f.write("from django.contrib.auth.decorators import login_required
from splunkdj.decorators.render import render_to

@render_to('" + app_name + ":home.html')
@login_required
def home(request):
    return {
        \"message\": \"Hello World from " + app_name + "!\",
        \"" + app_name + "\": \"" + app_name + "\"
    }")
f.close

FileUtils::mkdir_p app_name + '/django/' + app_name + '/static'
FileUtils::mkdir_p app_name + '/django/' + app_name + '/static/' + app_name
f = File.open(app_name + '/django/' + app_name + '/static/' + app_name + '/custom.css', 'w')
f.write(".main-area {
	border: solid;
	border-width: 1px;
	margin: 0px auto;
	margin-top: 30px;
	margin-bottom: 30px;
	padding: 30px;
	width: 1400px;
	background-color: white;
}")

data.each_key { |key|
    if data[key].include?('Extra')
        extra = data[key]['Extra'].downcase
        if extra == 'overlay'
            f.write("
    #overlay {
        border: none;
        border-radius: 5px 5px;
        border-color: black;
        border-width: 1px;
        width: 0%;
        height: 0%;
        background-color: #BB3B23;
        z-index: 100;
        top: 98%;
        position: fixed;
    }")
            f.close

            f = File.open(app_name + '/django/' + app_name + '/static/' + app_name + '/overlay.js', 'w')
        f.write("
var el = document.getElementById('mycanvas');
var ctx = el.getContext('2d');

ctx.lineWidth = 10;
ctx.lineJoin = ctx.lineCap = 'round';

var isDrawing, points = [ ];
var lastPoint;
var clientX, clientY, timeout;
var density = 50;
var rgbsegment = { r: 255, g: 0, b: 0 };
var rgbflip = true;
var rvote = false;
var gvote = false;
var bvote = false;
var infobutton = false;

function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function getRandomFloat(min, max) {
  return Math.random() * (max - min) + min;
}

el.onmousedown = function(e) {
  isDrawing = true;

  if (document.getElementById('drawstyle').value == 'sprayrect' || document.getElementById('drawstyle').value == 'spraycirc') {
      ctx.lineJoin = ctx.lineCap = 'round';
      clientX = getMousePos(null, e).x;
      clientY = getMousePos(null, e).y;
      ctx.fillStyle = document.getElementById('canvascolor').value;
      ctx.drawstyle = document.getElementById('canvascolor').value;
      timeout = setTimeout(function draw() {
        if (document.getElementById('drawstyle').value == 'sprayrect') {
            for (var i = density; i--; ) {
              var radius = 30;
              var offsetX = getRandomInt(-radius, radius);
              var offsetY = getRandomInt(-radius, radius);
              ctx.fillRect(clientX + offsetX, clientY + offsetY, 1, 1);
            }
        } else {
            for (var i = density; i--; ) {
              var angle = getRandomFloat(0, Math.PI*2);
              var radius = getRandomFloat(0, 20);
              ctx.fillRect(
                clientX + radius * Math.cos(angle),
                clientY + radius * Math.sin(angle), 
                1, 1);
            }
        }
        if (!timeout) return;
        timeout = setTimeout(draw, 50);
      }, 50);
  } else {
    points = [ ];
    points.push({ x: getMousePos(null, e).x, y: getMousePos(null, e).y });
    lastPoint = { x: getMousePos(null, e).x, y: getMousePos(null, e).y };
  }
};

el.onmousemove = function(e) {
  if (!isDrawing) return;

  ctx.lineWidth = document.getElementById('canvasline').value;
  var line = document.getElementById('canvasline').value;
  ctx.strokeStyle = document.getElementById('canvascolor').value;
  //ctx.fillStyle = document.getElementById('canvascolor2').value;
  origincolor = hexToRgb(document.getElementById('canvascolor').value);
  origincolor2 = hexToRgb(document.getElementById('canvascolor2').value);
  ctx.shadowOffsetX = 0;
  ctx.shadowOffsetY = 0;

  points.push({ x: getMousePos(null, e).x, y: getMousePos(null, e).y });
  ctx.globalAlpha = 1;
  ctx.shadowBlur = 0;

  if (document.getElementById('drawstyle').value == 'sketch') {

    ctx.beginPath();
    ctx.moveTo(points[points.length - 2].x, points[points.length - 2].y);
    ctx.lineTo(points[points.length - 1].x, points[points.length - 1].y);
    ctx.stroke();
    
    for (var i = 0, len = points.length; i < len; i++) {
      dx = points[i].x - points[points.length-1].x;
      dy = points[i].y - points[points.length-1].y;
      d = dx * dx + dy * dy;

      if (d < 1000) {
        ctx.beginPath();
        ctx.strokeStyle = 'rgba(' + origincolor.r + ', ' + origincolor.g + ', ' + origincolor.b + ', 0.3)';
        ctx.moveTo( points[points.length-1].x + (dx * 0.2), points[points.length-1].y + (dy * 0.2));
        ctx.lineTo( points[i].x - (dx * 0.2), points[i].y - (dy * 0.2));
        ctx.stroke();
      }
    }

  } else if (document.getElementById('drawstyle').value == 'flowsketch') {

    ctx.beginPath();
    ctx.globalAlpha = 1;
    ctx.moveTo(getMousePos(null, e).x, getMousePos(null, e).y);
    ctx.lineTo(lastPoint.x, lastPoint.y);
    ctx.stroke();
    ctx.closePath();

    for (var i = 0; i < 8; i++) {
        ctx.beginPath();
        ctx.globalAlpha = 1 - (i * 0.1);
        ctx.moveTo(getMousePos(null, e).x, getMousePos(null, e).y + ((1 * i) * document.getElementById('canvasline').value));
        ctx.lineTo(lastPoint.x, lastPoint.y + ((1 * i) * document.getElementById('canvasline').value));
        ctx.stroke();
        ctx.closePath();
    }

    lastPoint = { x: getMousePos(null, e).x, y: getMousePos(null, e).y };

  } else if (document.getElementById('drawstyle').value == 'rainbowsketch') {

    if (rgbsegment.r == 255 && rgbsegment.g < 255 && rgbsegment.b == 0) {
        rgbsegment.g += 5;
    } else if (rgbsegment.r > 0 && rgbsegment.g == 255 && rgbsegment.b == 0) {
        rgbsegment.r -= 5;
    } else if (rgbsegment.r == 0 && rgbsegment.g == 255 && rgbsegment.b < 255) {
        rgbsegment.b += 5;
    } else if (rgbsegment.r == 0 && rgbsegment.g > 0 && rgbsegment.b == 255) {
        rgbsegment.g -= 5;
    } else if (rgbsegment.r < 255 && rgbsegment.g == 0 && rgbsegment.b == 255) {
        rgbsegment.r += 5;
    } else if (rgbsegment.r == 255 && rgbsegment.g == 0 && rgbsegment.b > 0) {
        rgbsegment.b -= 5;
    } else {
        rgbsegment.r = 255;
        rgbsegment.g = 0;
        rgbsegment.b = 0;
    }

    ctx.strokeStyle = \"rgb(\" + rgbsegment.r + \", \" + rgbsegment.g + \", \" + rgbsegment.b + \")\";

    ctx.beginPath();
    ctx.moveTo(points[points.length - 2].x, points[points.length - 2].y);
    ctx.lineTo(points[points.length - 1].x, points[points.length - 1].y);
    ctx.stroke();
    
    for (var i = 0, len = points.length; i < len; i++) {
      dx = points[i].x - points[points.length-1].x;
      dy = points[i].y - points[points.length-1].y;
      d = dx * dx + dy * dy;

      if (d < 1000) {
        ctx.beginPath();
        ctx.strokeStyle = 'rgba(' + rgbsegment.r + ', ' + rgbsegment.g + ', ' + rgbsegment.b + ', 0.3)';
        ctx.moveTo( points[points.length-1].x + (dx * 0.2), points[points.length-1].y + (dy * 0.2));
        ctx.lineTo( points[i].x - (dx * 0.2), points[i].y - (dy * 0.2));
        ctx.stroke();
      }
    }
    
  } else if (document.getElementById('drawstyle').value == 'gradient') {

    if (origincolor.r == origincolor2.r) {
        rgbsegment.r = origincolor.r;
        rvote = true;
    } else if (origincolor.r < origincolor2.r) {
        if (rgbflip && rgbsegment.r < origincolor2.r) {
            rgbsegment.r += 1;
            if (rgbsegment.r == origincolor2.r) {
                rvote = true;
            }
        } else if (!rgbflip && rgbsegment.r > origincolor.r) {
            rgbsegment.r -= 1;
            if (rgbsegment.r == origincolor.r) {
                rvote = true;
            }
        }
    } else if (origincolor.r > origincolor2.r) {
        if (rgbflip && rgbsegment.r > origincolor2.r) {
            rgbsegment.r -= 1;
            if (rgbsegment.r == origincolor2.r) {
                rvote = true;
            }
        } else if (!rgbflip && rgbsegment.r < origincolor.r) {
            rgbsegment.r += 1;
            if (rgbsegment.r == origincolor.r) {
                rvote = true;
            }
        }
    }

    if (origincolor.g == origincolor2.g) {
        rgbsegment.g = origincolor.g;
        gvote = true;
    } else if (origincolor.g < origincolor2.g) {
        if (rgbflip && rgbsegment.g < origincolor2.g) {
            rgbsegment.g += 1;
            if (rgbsegment.g == origincolor2.g) {
                gvote = true;
            }
        } else if (!rgbflip && rgbsegment.g > origincolor.g) {
            rgbsegment.g -= 1;
            if (rgbsegment.g == origincolor.g) {
                gvote = true;
            }
        }
    } else if (origincolor.g > origincolor2.g) {
        if (rgbflip && rgbsegment.g > origincolor2.g) {
            rgbsegment.g -= 1;
            if (rgbsegment.g == origincolor2.g) {
                gvote = true;
            }
        } else if (!rgbflip && rgbsegment.g < origincolor.g) {
            rgbsegment.g += 1;
            if (rgbsegment.g == origincolor.g) {
                gvote = true;
            }
        }
    }

    if (origincolor.b == origincolor2.b) {
        rgbsegment.b = origincolor.b;
        bvote = true;
    } else if (origincolor.b < origincolor2.b) {
        if (rgbflip && rgbsegment.b < origincolor2.b) {
            rgbsegment.b += 1;
            if (rgbsegment.b == origincolor2.b) {
                bvote = true;
            }
        } else if (!rgbflip && rgbsegment.b > origincolor.b) {
            rgbsegment.b -= 1;
            if (rgbsegment.b == origincolor.b) {
                bvote = true;
            }
        }
    } else if (origincolor.b > origincolor2.b) {
        if (rgbflip && rgbsegment.b > origincolor2.b) {
            rgbsegment.b -= 1;
            if (rgbsegment.b == origincolor2.b) {
                bvote = true;
            }
        } else if (!rgbflip && rgbsegment.b < origincolor.b) {
            rgbsegment.b += 1;
            if (rgbsegment.b == origincolor.b) {
                bvote = true;
            }
        }
    }

    if (rvote && gvote && bvote) {
        if (rgbflip) {
            rgbflip = false;
        } else {
            rgbflip = true;
        }
        rvote = false;
        gvote = false;
        bvote = false;
    }

    ctx.strokeStyle = \"rgb(\" + rgbsegment.r + \", \" + rgbsegment.g + \", \" + rgbsegment.b + \")\";

    ctx.beginPath();
    ctx.moveTo(getMousePos(null, e).x, getMousePos(null, e).y);
    ctx.lineTo(lastPoint.x, lastPoint.y);
    ctx.stroke();

    lastPoint = { x: getMousePos(null, e).x, y: getMousePos(null, e).y };

  } else if (document.getElementById('drawstyle').value == 'pencil') {

    ctx.beginPath();
    ctx.moveTo(points[0].x, points[0].y);
    for (var i = 1; i < points.length; i++) {
      ctx.lineTo(points[i].x, points[i].y);
    }
    ctx.stroke();

  } else if (document.getElementById('drawstyle').value == 'deltapencil') {

    ctx.beginPath();
    ctx.moveTo(getMousePos(null, e).x, getMousePos(null, e).y);
    ctx.lineTo(lastPoint.x, lastPoint.y);
    ctx.stroke();
    ctx.closePath();
    lastPoint = { x: getMousePos(null, e).x, y: getMousePos(null, e).y }

  } else if (document.getElementById('drawstyle').value == 'fade') {

    ctx.shadowBlur = 10;
    ctx.shadowColor = document.getElementById('canvascolor').value;

    ctx.beginPath();
    ctx.moveTo(points[0].x, points[0].y);
    for (var i = 1; i < points.length; i++) {
      ctx.lineTo(points[i].x, points[i].y);
    }
    ctx.stroke(); 

  } else if (document.getElementById('drawstyle').value == \"flowrectangle\") {

    for (var i = 0; i < points.length; i++) {
      if (i < points.length - 1) {
        ctx.beginPath();
        var rectdia = getMidPoint(points[i], points[i + 1]);
        var rectradius = getDistance(points[i], rectdia) * 2;
        ctx.rect(points[i].x, points[i].y, rectradius, rectradius);
        ctx.stroke();
        ctx.closePath();
      }
    }

  } else if (document.getElementById('drawstyle').value == \"flowcircle\") {

    for (var i = 0; i < points.length; i++) {
      if (i < points.length - 1) {
        ctx.beginPath();
        var arcdia = getMidPoint(points[i], points[i + 1]);
        var arcradius = getDistance(points[i], arcdia);
        var arcangle = getAngle(points[i], points[i + 1]);
        ctx.arc(arcdia.x, arcdia.y, arcradius, arcangle, arcangle + 360);
        ctx.stroke();
        ctx.closePath();
      }
    }

  } else if (document.getElementById('drawstyle').value == 'highlight') {

    ctx.globalAlpha = 0.2;
    ctx.beginPath();
    ctx.moveTo(getMousePos(null, e).x, getMousePos(null, e).y);
    ctx.lineTo(lastPoint.x, lastPoint.y);
    ctx.stroke();
    ctx.closePath();
    lastPoint = { x: getMousePos(null, e).x, y: getMousePos(null, e).y }

  } else if (document.getElementById('drawstyle').value == 'flair') {

    ctx.drawstyle = \"black\";
    ctx.fillStyle = document.getElementById('canvascolor');

    /**for (var i = 0; i < points.length; i++) {
        ctx.beginPath();
        ctx.moveTo(points[i].x, points[i].y);
        ctx.lineTo(points[i].x - 1, points[i].y - 1);
        ctx.stroke();
        ctx.closePath();
    }**/

    var seccolor = hexToRgb(document.getElementById('canvascolor2').value);
    ctx.lineWidth = 1;
    var radius = Math.floor(Math.random() * document.getElementById('canvasline').value);

    //for (var i = 0; i < points.length; i++) {

        ctx.strokeStyle = \"rgba(\" + origincolor.r + \", \" + origincolor.g + \", \" + origincolor.b + \", \" + (Math.random() * 250) + \")\";
        ctx.fillStyle = \"rgba(\" + seccolor.r + \", \" + seccolor.g + \", \" + seccolor.b + \", \" + (Math.random() * 250) + \")\";
        ctx.globalAlpha = Math.random();

        ctx.beginPath();
        //ctx.arc(points[i].x, points[i].y, Math.floor(Math.random() * 10), false, Math.PI * 2, false);
        //ctx.arc(points[i].x, points[i].y, radius, false, Math.PI * 2, false);
        ctx.arc(getMousePos(null, e).x, getMousePos(null, e).y, radius, false, Math.PI * 2, false);
        ctx.fill();
        ctx.stroke();
    //}

  } else if (document.getElementById('drawstyle').value == 'star') {

    ctx.strokeStyle = generateColor();
    ctx.lineWidth = (Math.random() * 50) + 1;
    ctx.fillStyle = generateColor();
    ctx.globalAlpha = Math.random();
    ctx.lineJoin = \"miter\";
    var tradius = (Math.random() * 100) + 10;

    star(getMousePos(null, e).x, getMousePos(null, e).y, tradius, 5, 0.5);

  } else if (document.getElementById('drawstyle').value == 'pen') {

    ctx.beginPath();
    ctx.moveTo(points[0].x, points[0].y);
    for (var i = 1; i < points.length; i++) {
        ctx.lineTo(points[i].x, points[i].y);
    }
    ctx.stroke();
    ctx.closePath();

    ctx.beginPath();
    ctx.globalAlpha = 0.9;
    ctx.moveTo(points[0].x, points[0].y);
    for (var i = 1; i < points.length; i++) {
        ctx.lineTo(points[i].x, points[i].y - 1);
    }
    ctx.stroke();
    ctx.closePath();

    ctx.beginPath();
    ctx.globalAlpha = 0.8;
    ctx.moveTo(points[0].x, points[0].y);
    for (var i = 1; i < points.length; i++) {
        ctx.lineTo(points[i].x, points[i].y - 2);
    }
    ctx.stroke();
    ctx.closePath();

    ctx.beginPath();
    ctx.globalAlpha = 0.7;
    ctx.moveTo(points[0].x, points[0].y);
    for (var i = 1; i < points.length; i++) {
        ctx.lineTo(points[i].x, points[i].y - 3);
    }
    ctx.stroke();
    ctx.closePath();

    ctx.beginPath();
    ctx.globalAlpha = 0.6;
    ctx.moveTo(points[0].x, points[0].y);
    for (var i = 1; i < points.length; i++) {
        ctx.lineTo(points[i].x, points[i].y - 4);
    }
    ctx.stroke();
    ctx.closePath();

    ctx.beginPath();
    ctx.globalAlpha = 0.5;
    ctx.moveTo(points[0].x, points[0].y);
    for (var i = 1; i < points.length; i++) {
        ctx.lineTo(points[i].x, points[i].y - 5);
    }
    ctx.stroke();
    ctx.closePath();

    ctx.beginPath();
    ctx.globalAlpha = 0.4;
    ctx.moveTo(points[0].x, points[0].y);
    for (var i = 1; i < points.length; i++) {
        ctx.lineTo(points[i].x, points[i].y - 6);
    }
    ctx.stroke();
    ctx.closePath();

    ctx.beginPath();
    ctx.globalAlpha = 0.3;
    ctx.moveTo(points[0].x, points[0].y);
    for (var i = 1; i < points.length; i++) {
        ctx.lineTo(points[i].x, points[i].y - 7);
    }
    ctx.stroke();
    ctx.closePath();

  } else if (document.getElementById('drawstyle').value == 'rainbow') {

    if (rgbsegment.r == 255 && rgbsegment.g < 255 && rgbsegment.b == 0) {
        rgbsegment.g += 5;
    } else if (rgbsegment.r > 0 && rgbsegment.g == 255 && rgbsegment.b == 0) {
        rgbsegment.r -= 5;
    } else if (rgbsegment.r == 0 && rgbsegment.g == 255 && rgbsegment.b < 255) {
        rgbsegment.b += 5;
    } else if (rgbsegment.r == 0 && rgbsegment.g > 0 && rgbsegment.b == 255) {
        rgbsegment.g -= 5;
    } else if (rgbsegment.r < 255 && rgbsegment.g == 0 && rgbsegment.b == 255) {
        rgbsegment.r += 5;
    } else if (rgbsegment.r == 255 && rgbsegment.g == 0 && rgbsegment.b > 0) {
        rgbsegment.b -= 5;
    } else {
        rgbsegment.r = 255;
        rgbsegment.g = 0;
        rgbsegment.b = 0;
    }

    ctx.strokeStyle = \"rgb(\" + rgbsegment.r + \", \" + rgbsegment.g + \", \" + rgbsegment.b + \")\";

    ctx.beginPath();
    ctx.moveTo(getMousePos(null, e).x, getMousePos(null, e).y);
    ctx.lineTo(lastPoint.x, lastPoint.y);
    ctx.stroke();

    lastPoint = { x: getMousePos(null, e).x, y: getMousePos(null, e).y };

  } else if (document.getElementById('drawstyle').value == 'sprayrect' || document.getElementById('drawstyle').value == 'spraycirc') {

    clientX = getMousePos(null, e).x;
    clientY = getMousePos(null, e).y;

  } else if (document.getElementById('drawstyle').value == 'eraser') {

    ctx.strokeStyle = 'white';

    ctx.beginPath();
    ctx.moveTo(points[0].x, points[0].y);
    for (var i = 1; i < points.length; i++) {
      ctx.lineTo(points[i].x, points[i].y);
    }
    ctx.stroke();

  }
  
};

function getDistance(p1, p2) {

    return Math.sqrt(Math.pow((p2.x - p1.x), 2) + Math.pow((p2.y - p1.y), 2));

}

function getMidPoint(p1, p2) {

    return { x: ((p1.x + p2.x) / 2), y: ((p1.y + p2.y) / 2) };

}

function getAngle(originpoint, nextpoint) {
    var angle = Math.atan2(nextpoint.x - originpoint.x, nextpoint.y - originpoint.y);

    if(angle < 0) {
        angle += 360;
    }

    return angle;
}

el.onmouseup = function() {
  isDrawing = false;
  clearTimeout(timeout);
  points.length = 0;
};

function getMousePos(canvas, evt) {

    var canvas = document.getElementById('mycanvas');

    var rect = canvas.getBoundingClientRect();
    return {
        x: evt.clientX - rect.left,
        y: evt.clientY - rect.top
    };
}

function hexToRgb(hex) {

    var shorthandRegex = /^#?([a-f\\d])([a-f\\d])([a-f\\d])$/i;
    hex = hex.replace(shorthandRegex, function(m, r, g, b) {
        return r + r + g + g + b + b;
    });

    var result = /^#?([a-f\\d]{2})([a-f\\d]{2})([a-f\\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}

function overlaycolorchange() {

    if (document.getElementById('mycanvas').style.visibility == \"hidden\") {
        document.getElementById('overlaytextbox').style.color = document.getElementById('canvascolor').value;
    } else {
        var disc = hexToRgb(document.getElementById('canvascolor').value);
        rgbsegment.r = disc.r;
        rgbsegment.g = disc.g;
        rgbsegment.b = disc.b;
    }

}


function overlaydrawstylechange(ddel) {

    if (ddel.value == \"gradient\") {

        document.getElementById('canvascolor2').style.visibility = \"visible\";
        document.getElementById('canvascolor2').style.position = \"static\";

    } else {

        document.getElementById('canvascolor2').style.visibility = \"hidden\";
        document.getElementById('canvascolor2').style.position = \"fixed\";

    }

}

function clearcanvas() {

    var canvas = document.getElementById('mycanvas');

    if (canvas.style.visibility == \"visible\") {
        var context = canvas.getContext('2d');

        context.clearRect(0, 0, canvas.width, canvas.height);
    } else {
        document.getElementById('overlaytextbox').value = \"\";
    }

}


function showhideinfo() {
    if (!infobutton) {
        document.getElementById('information').style.position = \"fixed\";
        if (document.getElementById('mycanvas').style.visibility == \"visible\") {
            document.getElementById('drawstyle').style.marginLeft = \"7%\";
            document.getElementById('information').innerHTML = \"<center>Canvas Information:</center>The dropdown contains all the different drawing tools.<br>The first color is the main drawing color.<br>The secondary color is used/shown only when required by tool.<br>The Clear Canvas button will clean the canvas.<br>The textbox represents the line width of the tool.<br>The Switch To Textbox boutton will switch the canvas to a textbox.<br>The next dropdown will switch this overlay from half-screen to full-screen or vice versa.<br>The last dropdown changes the opacity of this overlay.\";
        } else {
            document.getElementById('canvascolor').style.marginLeft = \"7%\";
            document.getElementById('information').innerHTML = \"<center>Textbox Information:</center>The color is the font and border color, if it is updated, it will change all the font.<br>The clear button will remove all the text.<br>The Switch To Canvas button will go back to the canvas.<br>The next dropdown will switch this overlay from half-screen to full-screen or vice versa.<br>The last dropdown changes the opacity of this overlay.\"
        }
        infobutton = true;
    } else {
        document.getElementById('drawstyle').style.marginLeft = \"10px\";
        document.getElementById('canvascolor').style.marginLeft = \"10px\";
        document.getElementById('information').style.position = \"static\";
        document.getElementById('information').innerHTML = \"?\";
        infobutton = false;
    }
}

function overlayclose() {

    el = document.getElementById(\"overlay\");
    el.style.width = \"0%\";
    el.style.height = \"0%\";
    el.style.top = \"98%\";
    el.style.border = \"none\";
    document.getElementById('overlaybutton').onclick = overlayopen;
    document.getElementById('overlaybutton').value = \"Open\";
    document.getElementById('drawstyle').style.visibility = \"hidden\";
    document.getElementById('canvascolor').style.visibility = \"hidden\";
    document.getElementById('canvascolor2').style.visibility = \"hidden\";
    document.getElementById('clearcanvas').style.visibility = \"hidden\";

}

function overlayopen() {

    el = document.getElementById('overlay');
    el.style.width = \"100%\";

    if (document.getElementById('overlaysizechange').value == \"full\") {
        el.style.height = \"100%\";
        el.style.top = \"0%\";
    } else {
        el.style.height = \"50%\";
        el.style.top = \"50%\";
    }

    el.style.border = \"solid\";
    document.getElementById('overlaybutton').onclick = overlayclose;
    document.getElementById('overlaybutton').value = \"Close\";

    if (document.getElementById('mycanvas').style.visibility == \"visible\") {
        document.getElementById('drawstyle').style.visibility = \"visible\";
        document.getElementById('drawstyle').style.position = \"static\";

        if (document.getElementById('drawstyle').value == \"gradient\") {
            document.getElementById('canvascolor2').style.visibility = \"visible\";
            document.getElementById('canvascolor2').style.position = \"static\";
        }

        document.getElementById('clearcanvas').style.visibility = \"visible\";
        document.getElementById('clearcanvas').style.position = \"static\";

        document.getElementById('canvasline').style.visibility = \"visible\";
        document.getElementById('canvasline').style.position = \"static\";
    }

    document.getElementById('canvascolor').style.visibility = \"visible\"; 

}

function overlaysize() {

    if (document.getElementById('overlaysizechange').value == \"full\") {
        var el = document.getElementById('overlay');

        el.style.top = \"0\";
        el.style.height = \"100%\";

        document.getElementById('mycanvas').setAttribute(\"height\", \"900%\");
        document.getElementById('overlaytextbox').style.height = \"90%\";

    } else {

        var el = document.getElementById('overlay');

        el.style.top = \"50%\";
        el.style.height = \"50%\";

        document.getElementById('mycanvas').setAttribute(\"height\", \"400%\");
        document.getElementById('overlaytextbox').style.height = \"80%\";

    }

}

function opacitySwitch() {

    document.getElementById('overlay').style.opacity = document.getElementById('opacitylevel').value;

}

function switchVisibility() {

    if (document.getElementById('overlaytextbox').style.visibility == \"hidden\") {

        if (infobutton) {
            document.getElementById('canvascolor').style.marginLeft = \"7%\";
        }

        document.getElementById('mycanvas').style.visibility = \"hidden\";
        document.getElementById('mycanvas').style.position = \"fixed\";

        document.getElementById('drawstyle').style.visibility = \"hidden\";
        document.getElementById('drawstyle').style.position = \"fixed\";

        document.getElementById('canvascolor2').style.visibility = \"hidden\";
        document.getElementById('canvascolor2').style.position = \"fixed\";

        document.getElementById('clearcanvas').value = \"Clear Text\";

        document.getElementById('canvasline').style.visibility = \"hidden\";
        document.getElementById('canvasline').style.position = \"fixed\";

        document.getElementById('overlaytextbox').style.visibility = \"visible\";
        if (document.getElementById('overlaysizechange').value == \"full\") {
            document.getElementById('overlaytextbox').style.height = \"90%\";
        } else {
            document.getElementById('overlaytextbox').style.height = \"80%\";
        }

        document.getElementById('switchbutton').value = \"Switch To Canvas\";

        if (infobutton) {
            document.getElementById('information').style.position = \"fixed\";
            if (document.getElementById('mycanvas').style.visibility == \"visible\") {
                document.getElementById('information').innerHTML = \"<center>Canvas Information:</center>The dropdown contains all the different drawing tools.<br>The first color is the main drawing color.<br>The secondary color is used/shown only when required by tool.<br>The Clear Canvas button will clean the canvas.<br>The textbox represents the line width of the tool.<br>The Switch To Textbox boutton will switch the canvas to a textbox.\";
            } else {
                document.getElementById('information').innerHTML = \"<center>Textbox Information:</center>The color is the font and border color, if it is updated, it will change all the font.<br>The clear button will remove all the text.<br>The Switch To Canvas button will go back to the canvas.\"
            }
        }

    } else if (document.getElementById('overlaytextbox').style.visibility == \"visible\") {


        if (infobutton) {
            document.getElementById('canvascolor').style.marginLeft = \"10px\";
        }

        document.getElementById('mycanvas').style.visibility = \"visible\";
        document.getElementById('mycanvas').style.position = \"static\";

        document.getElementById('drawstyle').style.visibility = \"visible\";
        document.getElementById('drawstyle').style.position = \"static\";

        if (document.getElementById('drawstyle').value == \"gradient\") {
            document.getElementById('canvascolor2').style.visibility = \"visible\";
            document.getElementById('canvascolor2').style.position = \"static\";
        }

        document.getElementById('clearcanvas').value = \"Clear Canvas\";

        document.getElementById('canvasline').style.visibility = \"visible\";
        document.getElementById('canvasline').style.position = \"static\";

        document.getElementById('overlaytextbox').style.visibility = \"hidden\";
        document.getElementById('overlaytextbox').style.height = \"0%\";

        document.getElementById('switchbutton').value = \"Switch To Textbox\";

        if (infobutton) {
            document.getElementById('information').style.position = \"fixed\";
            if (document.getElementById('mycanvas').style.visibility == \"visible\") {
                document.getElementById('information').innerHTML = \"<center>Canvas Information:</center>The dropdown contains all the different drawing tools.<br>The first color is the main drawing color.<br>The secondary color is used/shown only when required by tool.<br>The Clear Canvas button will clean the canvas.<br>The textbox represents the line width of the tool.<br>The Switch To Textbox boutton will switch the canvas to a textbox.\";
            } else {
                document.getElementById('information').innerHTML = \"<center>Textbox Information:</center>The color is the font and border color, if it is updated, it will change all the font.<br>The clear button will remove all the text.<br>The Switch To Canvas button will go back to the canvas.\"
            }
        }

    }

}")
        end
    end
}

f = File.open(app_name + '/django/' + app_name + '/static/' + app_name + '/custom.js', 'w')
f.write("var urlprefix = document.URL.substr(0, document.URL.search(\"/dj\"));

require.config({
    baseUrl: urlprefix + \"/static/js\",
    waitSeconds: 0 // Disable require.js load timeout
});

//
// LIBRARY REQUIREMENTS
//
// In the require function, we include the necessary libraries and modules for
// the HTML dashboard. Then, we pass variable names for these libraries and
// modules as function parameters, in order.
// 
// When you add libraries or modules, remember to retain this mapping order
// between the library or module and its function parameter. You can do this by
// adding to the end of these lists, as shown in the commented examples below.

require([
    \"splunkjs/mvc\",
    \"splunkjs/mvc/utils\",
    \"splunkjs/mvc/tokenutils\",
    \"underscore\",
    \"jquery\",
    \"splunkjs/mvc/simplexml\",
    \"splunkjs/mvc/headerview\",
    \"splunkjs/mvc/footerview\",
    \"splunkjs/mvc/simplexml/dashboardview\",
    \"splunkjs/mvc/simplexml/element/chart\",
    \"splunkjs/mvc/simplexml/element/event\",
    \"splunkjs/mvc/simplexml/element/html\",
    \"splunkjs/mvc/simplexml/element/list\",
    \"splunkjs/mvc/simplexml/element/map\",
    \"splunkjs/mvc/simplexml/element/single\",
    \"splunkjs/mvc/simplexml/element/table\",
    \"splunkjs/mvc/simpleform/formutils\",
    \"splunkjs/mvc/simpleform/input/dropdown\",
    \"splunkjs/mvc/simpleform/input/radiogroup\",
    \"splunkjs/mvc/simpleform/input/multiselect\",
    \"splunkjs/mvc/simpleform/input/checkboxgroup\",
    \"splunkjs/mvc/simpleform/input/text\",
    \"splunkjs/mvc/simpleform/input/timerange\",
    \"splunkjs/mvc/simpleform/input/submit\",
    \"splunkjs/mvc/searchmanager\",
    \"splunkjs/mvc/savedsearchmanager\",
    \"splunkjs/mvc/postprocessmanager\",
    \"splunkjs/mvc/simplexml/urltokenmodel\"
    // Add comma-separated libraries and modules manually here, for example:
    // ...\"splunkjs/mvc/simplexml/urltokenmodel\",
    // \"splunkjs/mvc/checkboxview\"
    ],
    function(
        mvc,
        utils,
        TokenUtils,
        _,
        $,
        DashboardController,
        HeaderView,
        FooterView,
        Dashboard,
        ChartElement,
        EventElement,
        HtmlElement,
        ListElement,
        MapElement,
        SingleElement,
        TableElement,
        FormUtils,
        DropdownInput,
        RadioGroupInput,
        MultiSelectInput,
        CheckboxGroupInput,
        TextInput,
        TimeRangeInput,
        SubmitButton,
        SearchManager,
        SavedSearchManager,
        PostProcessManager,
        UrlTokenModel

        // Add comma-separated parameter names here, for example: 
        // ...UrlTokenModel, 
        // CheckboxView
        ) {


        var pageLoading = true;
        // 
        // TOKENS
        //

        // Create token namespaces
        var urlTokenModel = new UrlTokenModel();
        mvc.Components.registerInstance('url', urlTokenModel);
        var defaultTokenModel = mvc.Components.getInstance('default', {create: true});
        var submittedTokenModel = mvc.Components.getInstance('submitted', {create: true});

        urlTokenModel.on('url:navigate', function() {
            defaultTokenModel.set(urlTokenModel.toJSON());
            if (!_.isEmpty(urlTokenModel.toJSON()) && !_.all(urlTokenModel.toJSON(), _.isUndefined)) {
                submitTokens();
            } else {
                submittedTokenModel.clear();
            }
        });

        // Initialize tokens
        defaultTokenModel.set(urlTokenModel.toJSON());

        function submitTokens() {
            // Copy the contents of the defaultTokenModel to the submittedTokenModel and urlTokenModel
            FormUtils.submitForm({ replaceState: pageLoading });
        }

        function setToken(name, value) {
            defaultTokenModel.set(name, value);
            submittedTokenModel.set(name, value);
        }

        function unsetToken(name) {
            defaultTokenModel.unset(name);
            submittedTokenModel.unset(name);
        }
        //
        // SEARCH MANAGERS
        //
        ")
chartCount = 0
timeCount = 0
data.each_key { |key|
    unless data[key].include?('Extra')
        charttype = data[key]['ChartType'].downcase
        panelname = data[key]['PanelName']
        unless (charttype == 'text' or charttype == 'radio' or charttype == 'dropdown' or charttype == 'checkboxgroup' or charttype == 'multiselect' or charttype == 'timerangepicker')
            hasTime = false
            data.each_key { |key2|
                unless data[key2].include?('Extra')
                    ctype = data[key2]['ChartType'].downcase
                    if ctype == 'timerangepicker'
                        pname = data[key2]['Search']
                        if pname == panelname
                            hasTime = true
                            timeselect = timeCount
                        end
                    end
                end
                timeCount += 1
            }
            search = data[key]['Search']
            if hasTime
                f.write("var search#{chartCount} = new SearchManager({
            \"id\": \"search#{chartCount}\",
            \"search\": \"#{search}\",
            \"latest_time\": \"$field#{timeselect}.latest$\",
            \"cancelOnUnload\": true,
            \"status_buckets\": 0,
            \"earliest_time\": \"$field#{timeselect}.earliest$\",
            \"app\": utils.getCurrentApp(),
            \"auto_cancel\": 90,
            \"preview\": true,
            \"runWhenTimeIsUndefined\": false
        }, {tokens: true});
        ")
            else
                f.write("var search#{chartCount} = new SearchManager({
            \"id\": \"search#{chartCount}\",
            \"search\": \"#{search}\",
            \"latest_time\": \"\",
            \"cancelOnUnload\": true,
            \"status_buckets\": 0,
            \"earliest_time\": \"\",
            \"app\": utils.getCurrentApp(),
            \"auto_cancel\": 90,
            \"preview\": true,
            \"runWhenTimeIsUndefined\": false
        }, {tokens: true});
        ")
            end
        end
    end
    chartCount += 1
}

f.write("
        //
        // SPLUNK HEADER AND FOOTER
        //

        new HeaderView({
            id: 'header',
            section: 'dashboards',
            el: $('.header'),
            acceleratedAppNav: true,
            useSessionStorageCache: true
        }, {tokens: true}).render();

        new FooterView({
            id: 'footer',
            el: $('.footer')
        }, {tokens: true}).render();


        //
        // DASHBOARD EDITOR
        //

        //
        // VIEWS: VISUALIZATION ELEMENTS
        //
        ")

chartCount = 0
data.each_key { |key|
    unless data[key].include?('Extra')
        charttype = data[key]['ChartType'].downcase
        if data[key].include?('ColorScheme')
            colorscheme = data[key]['ColorScheme']
            colorscheme = colorscheme.gsub('#', '0x')
        end
        if (charttype == 'text' or charttype == 'radio' or charttype == 'dropdown' or charttype == 'checkboxgroup' or charttype == 'multiselect' or charttype == 'timerangepicker')
            # Vroom
        elsif charttype == 'event'
            f.write("var element#{chartCount} = new EventElement({
            \"id\": \"element#{chartCount}\",
            \"type\": \"list\",
            \"table.wrap\": \"1\",
            \"list.drilldown\": \"full\",
            \"count\": 10,
            \"raw.drilldown\": \"full\",
            \"rowNumbers\": \"0\",
            \"table.drilldown\": \"all\",
            \"maxLines\": 5,
            \"list.wrap\": \"1\",
            \"managerid\": \"search#{chartCount}\",
            \"el\": $('#element#{chartCount}')
        }, {tokens: true, tokenNamespace: \"submitted\"}).render();
        ")
        elsif charttype == 'table'
            f.write("var element#{chartCount} = new TableElement({
            \"id\": \"element#{chartCount}\",
            \"count\": 10,
            \"dataOverlayMode\": \"none\",
            \"drilldown\": \"cell\",
            \"rowNumbers\": \"false\",
            \"wrap\": \"true\",
            \"managerid\": \"search#{chartCount}\",
            \"el\": $('#element#{chartCount}')
        }, {tokens: true, tokenNamespace: \"submitted\"}).render();
        ")
        elsif charttype == 'single'
            f.write("var element#{chartCount} = new SingleElement({
            \"id\": \"element#{chartCount}\",
            \"linkView\": \"search\",
            \"drilldown\": \"none\",
            \"managerid\": \"search#{chartCount}\",
            \"el\": $('#element#{chartCount}')
        }, {tokens: true, tokenNamespace: \"submitted\"}).render();
        ")
        elsif charttype == 'map'
            f.write("var element#{chartCount} = new MapElement({
            \"id\": \"element#{chartCount}\",
            \"resizable\": true,
            \"managerid\": \"search#{chartCount}\",
            \"el\": $('#element#{chartCount}')
        }, {tokens: true, tokenNamespace: \"submitted\"}).render();
        ")
        else        
            f.write("var element#{chartCount} = new ChartElement({
            \"id\": \"element#{chartCount}\",
            \"charting.chart\": \"#{charttype}\",")
            if data[key].include? 'ColorScheme'
                f.write("
            \"charting.seriesColors\": \"" + colorscheme + "\",")
            end
            f.write("
            \"resizable\": false,
            \"managerid\": \"search#{chartCount}\",
            \"el\": $('#element#{chartCount}')
        }, {tokens: true, tokenNamespace: \"submitted\"}).render();
        ")
        end
    end
    chartCount += 1
}

f.write("
        //
        // VIEWS: FORM INPUTS
        //
        ")

chartCount = 0
data.each_key { |key|
    unless data[key].include?('Extra')
        charttype = data[key]['ChartType'].downcase
        inputvalue = data[key]['Search']
        if inputvalue == '$'
            inputvalue = inputvalue.gsub('$', '')
        end
        if charttype == 'text'
            f.write("var input#{chartCount} = new TextInput({
            \"id\": \"input#{chartCount}\",
            \"default\": \"\",
            \"value\": \"$form.#{inputvalue}$\",
            \"el\": $('#input#{chartCount}')
        }, {tokens: true}).render();

        input#{chartCount}.on(\"change\", function(newValue) {
            FormUtils.handleValueChange(input#{chartCount});
        });
        ")
        elsif charttype == 'radio'
            choices = data[key]['Choices'].join(', ').gsub('=>', ': ')
            f.write("var input#{chartCount} = new RadioGroupInput({
            \"id\": \"input#{chartCount}\",
            \"choices\": [#{choices}],
            \"selectFirstChoice\": false,
            \"default\": \"1\",
            \"searchWhenChanged\": true,
            \"value\": \"$form.#{inputvalue}$\",
            \"el\": $('#input#{chartCount}')
        }, {tokens: true}).render();

        input#{chartCount}.on(\"change\", function(newValue) {
            FormUtils.handleValueChange(input#{chartCount});
        });
        ")
        elsif charttype == 'dropdown'
            choices = data[key]['Choices'].join(', ').gsub('=>', ': ')
            f.write("var input#{chartCount} = new DropdownInput({
            \"id\": \"input#{chartCount}\",
            \"choices\": [#{choices}],
            \"selectFirstChoice\": false,
            \"searchWhenChanged\": true,
            \"showClearButton\": true,
            \"value\": \"$form.#{inputvalue}$\",
            \"el\": $('#input#{chartCount}')
        }, {tokens: true}).render();

        input#{chartCount}.on(\"change\", function(newValue) {
            FormUtils.handleValueChange(input#{chartCount});
        });
        ")
        elsif charttype == 'checkboxgroup'
            choices = data[key]['Choices'].join(', ').gsub('=>', ': ')
            f.write("var input#{chartCount} = new CheckboxGroupInput({
            \"id\": \"input#{chartCount}\",
            \"choices\": [#{choices}],
            \"delimiter\": \"AND\",
            \"searchWhenChanged\": true,
            \"value\": \"$form.#{inputvalue}$\",
            \"el\": $('#input#{chartCount}')
        }, {tokens: true}).render();

        input#{chartCount}.on(\"change\", function(newValue) {
            FormUtils.handleValueChange(input#{chartCount});
        });
        ")
        elsif charttype == 'multiselect'
            choices = data[key]['Choices'].join(', ').gsub('=>', ': ')
            f.write("var input#{chartCount} = new MultiSelectInput({
            \"id\": \"input#{chartCount}\",
            \"choices\": [#{choices}],
            \"delimiter\": \"AND\",
            \"searchWhenChanged\": true,
            \"value\": \"$form.#{inputvalue}$\",
            \"el\": $('#input#{chartCount}')
        }, {tokens: true}).render();

        input#{chartCount}.on(\"change\", function(newValue) {
            FormUtils.handleValueChange(input#{chartCount});
        });
        ")
        elsif charttype == 'timerangepicker'
            f.write("var input#{chartCount} = new TimeRangeInput({
            \"id\": \"input#{chartCount}\",
            \"default\": {\"latest_time\": null, \"earliest_time\": \"0\"},
            \"searchWhenChanged\": true,
            \"earliest_time\": \"$form.field#{chartCount}.earliest$\",
            \"latest_time\": \"$form.field#{chartCount}.latest$\",
            \"el\": $('#input#{chartCount}')
        }, {tokens: true}).render();

        input#{chartCount}.on(\"change\", function(newValue) {
            FormUtils.handleValueChange(input#{chartCount});
        });
        ")
        else
            # Kabow
        end
    end
    chartCount += 1
}

f.write("

        // This section is only included for forms
        // Initialize time tokens to default
        if (!defaultTokenModel.has('earliest') && !defaultTokenModel.has('latest')) {
            defaultTokenModel.set({ earliest: '0', latest: '' });
        }

        submitTokens();


        //
        // DASHBOARD READY
        //

        DashboardController.ready();
        pageLoading = false;

    }
);")
f.close

FileUtils::mkdir_p app_name + '/django/' + app_name + '/templates'
f = File.open(app_name + '/django/' + app_name + '/templates/home.html', 'w')
f.write("<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"utf-8\" />
    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />
    <title>App Documentation Home</title>
    <link rel=\"shortcut icon\" href=\"{{SPLUNKWEB_URL_PREFIX}}/static/img/favicon.ico\" />
    <link rel=\"stylesheet\" type=\"text/css\" href=\"{{SPLUNKWEB_URL_PREFIX}}/static/css/build/bootstrap.min.css\" />
    <link rel=\"stylesheet\" type=\"text/css\" media=\"all\" href=\"{{SPLUNKWEB_URL_PREFIX}}/static/css/build/pages/dashboard-simple-bootstrap.min.css\" />
    <link rel=\"stylesheet\" type=\"text/css\" media=\"all\" href=\"{{SPLUNKWEB_URL_PREFIX}}/static/app/search/dashboard.css\" />
    <script src=\"{{SPLUNKWEB_URL_PREFIX}}/config?autoload=1\"></script>
    <script src=\"{{SPLUNKWEB_URL_PREFIX}}/static/js/i18n.js\"></script>
    <script src=\"{{SPLUNKWEB_URL_PREFIX}}/i18ncatalog?autoload=1\"></script>
    <script src=\"{{SPLUNKWEB_URL_PREFIX}}/static/js/build/simplexml.min/config.js\"></script>
    <link rel=\"stylesheet\" type=\"text/css\" href=\"{{STATIC_URL}}{{app_name}}/custom.css\" />
    <script src=\"{{STATIC_URL}}{{app_name}}/custom.js\"></script>
    <!--[if IE 7]><link rel=\"stylesheet\" href=\"{{SPLUNKWEB_URL_PREFIX}}/static/css/sprites-ie7.css\" /><![endif]-->
</head>
<body class=\"simplexml preload\">

<!-- 
BEGIN LAYOUT
This section contains the layout for the dashboard. Splunk uses proprietary
styles in <div> tags, similar to Bootstrap's grid system. 
-->
<a class=\"navSkip\" href=\"#navSkip\" tabindex=\"1\">Screen reader users, click here to skip the navigation bar</a>
<div class=\"header\">
    <div id=\"placeholder-splunk-bar\">
        <a href=\"{{SPLUNKWEB_URL_PREFIX}}/app/launcher/home\" class=\"brand\" title=\"splunk > listen to your data\">splunk<strong>></strong></a>
    </div>
    <div id=\"placeholder-app-bar\"></div>
</div>
<a id=\"navSkip\"></a>
<div>")


data.each_key { |key|
    if data[key].include?('Extra')
        extra = data[key]['Extra'].downcase
        if extra == 'overlay'
        f.write("
    <div id=\"overlay\">
        <input type=\"submit\" value=\"Open\" onclick='overlayopen()' id=\"overlaybutton\"><br>
        <button id=\"information\" onclick=\"showhideinfo()\" style=\"margin-left: 5%; margin-bottom: 7px;\">?</button>
        <select id=\"drawstyle\" style=\"visibility: hidden; margin-left: 10px; width: 150px;\" onchange=\"overlaydrawstylechange(this)\">
            <option value=\"pencil\">Pencil</option>
            <option value=\"deltapencil\">Delta: Pencil</option>
            <option value=\"sketch\">Sketch</option>
            <option value=\"highlight\">Highlight</option>
            <option value=\"rainbowsketch\">Rainbow Sketch</option>
            <option value=\"gradient\">Gradient</option>
            <option value=\"flowsketch\">Flow Sketch</option>
            <option value=\"flowcircle\">Flow Circle</option>
            <option value=\"flowrectangle\">Flow Rectangle</option>
            <option value=\"star\">Star</option>
            <option value=\"flair\">Flair</option>
            <option value=\"pen\">Pen</option>
            <option value=\"fade\">Fade</option>
            <option value=\"rainbow\">Rainbow</option>
            <option value=\"sprayrect\">Spray-Rectangle</option>
            <option value=\"spraycirc\">Spray-Circle</option>
            <option value=\"eraser\">Eraser</option>
        </select>
        <input type=\"color\" id=\"canvascolor\" style=\"visibility: hidden; margin-left: 10px; width: 100px;\" onchange=\"overlaycolorchange()\">
        <input type=\"color\" id=\"canvascolor2\" style=\"visibility: hidden; position: fixed; margin-left: 10px; width: 100px\">
        <input type=\"submit\" id=\"clearcanvas\" value=\"Clear Canvas\" onclick=\"clearcanvas()\" style=\"visibility: hidden; margin-left: 10px; margin-bottom: 7px;\">
        <input type=\"text\" id=\"canvasline\" value=\"1\" style=\"margin-left: 10px; width: 100px;\">
        <input type=\"submit\" value=\"Switch To Textbox\" id=\"switchbutton\" onclick=\"switchVisibility()\" style=\"margin-left: 10px; margin-bottom: 7px;\">
        <select id=\"overlaysizechange\" style=\"margin-left: 10px; width: 100px;\" onchange=\"overlaysize()\">
            <option value=\"half\">Half Screen</option>
            <option value=\"full\">Full Screen</option>
        </select>
        <select id=\"opacitylevel\" style=\"margin-left: 10px; width: 100px;\" onchange=\"opacitySwitch()\">
            <option value=\"1\">Opacity: 1</option>
            <option value=\"0.9\">Opacity: 0.9</option>
            <option value=\"0.8\">Opacity: 0.8</option>
            <option value=\"0.7\">Opacity: 0.7</option>
            <option value=\"0.6\">Opacity: 0.6</option>
            <option value=\"0.5\">Opacity: 0.5</option>
            <option value=\"0.4\">Opacity: 0.4</option>
            <option value=\"0.3\">Opacity: 0.3</option>
            <option value=\"0.2\">Opacity: 0.2</option>
        </select>
        <canvas id=\"mycanvas\" width=\"1500%\" height=\"400%\" style=\"background-color: white; border: solid; margin-left: 5%; visibility: visible\" onmousedown=\"mouseisdown()\" onmouseup=\"mouseisup()\"></canvas>
        <textarea id=\"overlaytextbox\" style=\"background-color: white; border: solid; margin-left: 5%; width: 88.5%; visibility: hidden;\">
        </textarea>
    </div>")
        end
    end
}

f.write("
    <div class=\"main-area\">
        ")

chartCount = 0
data.each_key { |key|
    unless data[key].include?('Extra')
        charttype = data[key]['ChartType'].downcase
        rowtype = data[key]['RowType'].downcase
        panelname = data[key]['PanelName']
        if (charttype == 'text' or charttype == 'radio' or charttype == 'dropdown' or charttype == 'checkboxgroup' or charttype == 'multiselect' or charttype == 'timerangepicker')
            isForm = true
        elsif (charttype == 'event' or charttype == 'table' or charttype == 'single' or charttype == 'map')
            isForm = false
        else
            isForm = false
            charttype = 'chart'
        end

        if rowtype == 'double'
            if tablecount == 0
                f.write("<table width=\"100%\">
            <tr>
                <td width=\"50%\">
                    ")
            end
        elsif rowtype == 'triple'
            if tablecount == 0
                f.write("<table width=\"100%\">
            <tr>
                <td width=\"33%\">
                    ")
            end
        end
        if isForm
            if (rowtype == 'triple' or rowtype == 'double')
                f.write("<div class=\"input input-#{charttype}\" id=\"input#{chartCount}\">
                        <label>#{panelname}</label>
                    </div>
                ")
            else
                f.write("<div class=\"input input-#{charttype}\" id=\"input#{chartCount}\">
            <label>#{panelname}</label>
        </div>
        ")
            end
        elsif !isForm
            if (rowtype == 'triple' or rowtype == 'double')
                f.write("<div class=\"panel-element-row\">
                        <div id=\"element#{chartCount}\" class=\"dashboard-element #{charttype}\">
                            <div class=\"panel-head\">
                                <h3>#{panelname}</h3>
                            </div>
                        </div>
                    </div>
                ")
            else
                f.write("<div class=\"panel-element-row\">
            <div id=\"element#{chartCount}\" class=\"dashboard-element #{charttype}\">
                <div class=\"panel-head\">
                    <h3>#{panelname}</h3>
                </div>
            </div>
        </div>
        <br>
        <br>
        ")
            end
        end
        if rowtype == 'double'
            if tablecount == 0
                f.write("</td>
                <td>
                    ")
                tablecount += 1
            elsif tablecount == 1
                f.write("</td>
            </tr>
        </table>
        ")
                tablecount = 0
            end
        elsif rowtype == 'triple'
            if tablecount <= 1
                f.write("</td>
                <td width=\"33%\">
                    ")
                tablecount += 1
            elsif tablecount == 2
                f.write("</td>
            </tr>
        </table>
    ")
                tablecount = 0
            end
        end
    end
    chartCount += 1
}

f.write("
    </div>
</div>
<div class=\"footer\"></div>")

data.each_key { |key|
    if data[key].include?('Extra')
        extra = data[key]['Extra'].downcase
        if extra == 'overlay'
            f.write("
<script src=\"{{STATIC_URL}}{{app_name}}/overlay.js\"></script>")
        end
    end
}

f.write("
</body>
</html>")
f.close

FileUtils::mkdir_p app_name + '/django/' + app_name + '/templatetags'
f = File.open(app_name + '/django/' + app_name + '/templatetags/__init__.py', 'w')
f.write("")
f.close

f = File.open(app_name + '/README', 'w')
f.write("Introduction
------------
Describe your application here.

Installation
------------
Describe how to install your application here (if applicable).

Usage
-----
Describe how to use your application here.

TODO:
-----
If you intend to upload this application to Splunk Apps, we strongly recommend 
that you update the app.conf file (located in your app's /default directory) 
with your name, a one-sentence description of your application, and the
version number of your application.")
f.close

FileUtils::mkdir_p app_name + '/lookups'

FileUtils::mkdir_p app_name + '/static'

