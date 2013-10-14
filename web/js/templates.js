var bvpApplyTemplate = function(ev) {
	var comment = $("textarea[name=comment]").first();
	if (comment.data('changed')) {
		if(!confirm("This will overwrite your changes in the description. Continue?")) return;
	}
	comment.val($(ev.target).data('template').content).data('changed', false)
}

var bvpInitTemplates = function() {
	if (BVP_TEMPLATES == undefined || BVP_TEMPLATES.length == 0) return;
	var tlist = $("<ul>")
		.addClass("bvp_template_list")
		.append($("<li>").text("Templates:"))
	BVP_TEMPLATES.forEach(function(t) {
		tlist.append(
			$("<li>").addClass("bvp_template")
				.text(t.name)
				.attr("title", t.description)
				.data("template", t)
				.click(bvpApplyTemplate)
		)
	});
	$("textarea[name=comment]").first()
		.before(tlist)
		.data('changed', false)
		.change(function(){$(this).data('changed', true)});
}

$(bvpInitTemplates);
