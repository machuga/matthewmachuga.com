(function() {
	document.addEventListener("DOMContentLoaded", function(event) {
		const subjectField = document.getElementById('subject');

		if (!subjectField || !location.search) { return; }

		const urlParam = name => {
			const cleanName = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
			const regex = new RegExp("[\\?&]" + name + "=([^&#]*)");
			const [_, value] = regex.exec(location.search);

			return value && decodeURIComponent(value.replace(/\+/g, " "));
		}

		const topic = urlParam('topic');

		if (topic) {
			subjectField.value = topic;
		}
	});
}());
